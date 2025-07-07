#!/usr/bin/env python3
"""
Script d'engagement Instagram unifié
Basé sur la nouvelle architecture modulaire
"""

import sys
import json
import argparse
import random
import time
import os
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor, as_completed

# Ajouter le répertoire parent au path pour importer les modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from base_instagram_client import BaseInstagramClient
from services.hashtag_service import HashtagService
from services.user_service import UserService
from services.message_service import MessageService


class EngagementService:
    """Service d'engagement Instagram unifié"""

    def __init__(self, config_file_path, campagne_id=None):
        """
        Initialiser le service d'engagement

        Args:
            config_file_path: Chemin vers le fichier de configuration JSON
            campagne_id: ID de la campagne (optionnel)
        """
        self.config_file_path = config_file_path
        self.campagne_id = campagne_id
        self.start_time = datetime.now()

        # Charger la configuration
        self.config = self.load_config()

        # Créer le dossier stats s'il n'existe pas
        self.stats_dir = os.path.join(os.path.dirname(__file__), "..", "..", "stats")
        os.makedirs(self.stats_dir, exist_ok=True)

        # Initialiser les services
        self.hashtag_service = HashtagService()
        self.user_service = UserService()
        self.message_service = MessageService()

        # Résultats de la session
        self.session_results = []

    def load_config(self):
        """Charger la configuration depuis le fichier JSON"""
        try:
            with open(self.config_file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            raise Exception(f"Erreur lors du chargement de la configuration: {e}")

    def run_engagement(self):
        """Exécuter l'engagement pour tous les comptes"""
        try:
            print(json.dumps({
                "status": "started",
                "message": f"Démarrage de l'engagement pour {len(self.config)} comptes",
                "timestamp": self.start_time.isoformat()
            }))

            # Exécuter l'engagement pour chaque compte
            for account_config in self.config:
                result = self.run_account_engagement(account_config)
                self.session_results.append(result)

            # Générer le rapport final
            final_report = self.generate_final_report()

            print(json.dumps(final_report))
            return final_report

        except Exception as e:
            error_result = {
                "status": "error",
                "message": f"Erreur lors de l'engagement: {str(e)}",
                "timestamp": datetime.now().isoformat()
            }
            print(json.dumps(error_result))
            return error_result

    def run_account_engagement(self, account_config):
        """Exécuter l'engagement pour un compte spécifique"""
        username = account_config["username"]
        password = account_config["password"]
        hashtags = account_config.get("hashtags", [])
        targeted_accounts = account_config.get("targeted_accounts", [])

        print(json.dumps({
            "status": "account_started",
            "username": username,
            "message": f"Démarrage de l'engagement pour {username}",
            "timestamp": datetime.now().isoformat()
        }))

        try:
            # Initialiser le client Instagram
            client = BaseInstagramClient(username, password)

            # Résultats pour ce compte
            account_result = {
                "username": username,
                "hashtag_likes": {},
                "follower_likes": {},
                "total_likes": 0,
                "session_start": datetime.now().isoformat(),
                "session_end": None,
                "status": "completed"
            }

            # Engagement sur les hashtags
            if hashtags:
                hashtag_result = self.run_hashtag_engagement(client, hashtags)
                account_result["hashtag_likes"] = hashtag_result
                account_result["total_likes"] += sum(
                    data.get("successful", 0) for data in hashtag_result.values()
                )

            # Engagement sur les comptes ciblés
            if targeted_accounts:
                follower_result = self.run_follower_engagement(client, targeted_accounts)
                account_result["follower_likes"] = follower_result
                account_result["total_likes"] += sum(
                    data.get("successful", 0) for data in follower_result.values()
                )

            account_result["session_end"] = datetime.now().isoformat()

            print(json.dumps({
                "status": "account_completed",
                "username": username,
                "total_likes": account_result["total_likes"],
                "timestamp": datetime.now().isoformat()
            }))

            return account_result

        except Exception as e:
            error_result = {
                "username": username,
                "status": "error",
                "message": f"Erreur pour {username}: {str(e)}",
                "timestamp": datetime.now().isoformat()
            }
            print(json.dumps(error_result))
            return error_result

    def run_hashtag_engagement(self, client, hashtags):
        """Exécuter l'engagement sur les hashtags"""
        results = {}

        for hashtag_config in hashtags:
            hashtag_name = hashtag_config.get("hashtag") if isinstance(hashtag_config, dict) else hashtag_config
            cursor = hashtag_config.get("cursor") if isinstance(hashtag_config, dict) else None

            try:
                # Utiliser le service de hashtag
                result = self.hashtag_service.like_random_posts(
                    client,
                    hashtag_name,
                    max_likes=random.randint(3, 8),
                    cursor=cursor
                )

                results[hashtag_name] = {
                    "successful": result.get("successful", 0),
                    "posts_liked": result.get("posts_liked", []),
                    "cursor": result.get("cursor"),
                    "status": "completed"
                }

                # Pause aléatoire entre les hashtags
                time.sleep(random.uniform(2, 5))

            except Exception as e:
                results[hashtag_name] = {
                    "successful": 0,
                    "posts_liked": [],
                    "cursor": cursor,
                    "status": "error",
                    "error": str(e)
                }

        return results

    def run_follower_engagement(self, client, targeted_accounts):
        """Exécuter l'engagement sur les comptes ciblés"""
        results = {}

        for account_config in targeted_accounts:
            account_name = account_config.get("account") if isinstance(account_config, dict) else account_config
            cursor = account_config.get("cursor") if isinstance(account_config, dict) else None

            try:
                # Utiliser le service utilisateur
                result = self.user_service.like_follower_posts(
                    client,
                    account_name,
                    max_likes=random.randint(2, 6),
                    cursor=cursor
                )

                results[account_name] = {
                    "successful": result.get("successful", 0),
                    "posts_liked": result.get("posts_liked", []),
                    "cursor": result.get("cursor"),
                    "status": "completed"
                }

                # Pause aléatoire entre les comptes
                time.sleep(random.uniform(3, 7))

            except Exception as e:
                results[account_name] = {
                    "successful": 0,
                    "posts_liked": [],
                    "cursor": cursor,
                    "status": "error",
                    "error": str(e)
                }

        return results

    def generate_final_report(self):
        """Générer le rapport final de la session"""
        end_time = datetime.now()
        duration = (end_time - self.start_time).total_seconds()

        total_likes = sum(
            result.get("total_likes", 0)
            for result in self.session_results
            if result.get("status") == "completed"
        )

        successful_accounts = len([
            result for result in self.session_results
            if result.get("status") == "completed"
        ])

        failed_accounts = len([
            result for result in self.session_results
            if result.get("status") == "error"
        ])

        return {
            "status": "completed",
            "session_start": self.start_time.isoformat(),
            "session_end": end_time.isoformat(),
            "duration_seconds": duration,
            "total_accounts": len(self.config),
            "successful_accounts": successful_accounts,
            "failed_accounts": failed_accounts,
            "total_likes": total_likes,
            "sessions": self.session_results,
            "campagne_id": self.campagne_id
        }


def main():
    """Point d'entrée principal"""
    parser = argparse.ArgumentParser(description="Service d'engagement Instagram unifié")
    parser.add_argument("config_file", help="Chemin vers le fichier de configuration JSON")
    parser.add_argument("--campagne-id", help="ID de la campagne (optionnel)")

    args = parser.parse_args()

    try:
        # Créer et exécuter le service d'engagement
        service = EngagementService(args.config_file, args.campagne_id)
        result = service.run_engagement()

        # Le résultat est déjà affiché en JSON
        sys.exit(0 if result.get("status") == "completed" else 1)

    except Exception as e:
        error_result = {
            "status": "error",
            "message": f"Erreur fatale: {str(e)}",
            "timestamp": datetime.now().isoformat()
        }
        print(json.dumps(error_result))
        sys.exit(1)


if __name__ == "__main__":
    main()
