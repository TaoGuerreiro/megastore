# frozen_string_literal: true
"""
Script pour liker des posts Instagram
"""

import sys
import argparse
import json
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core.client import InstagramClient
from core.logger import InstagramLogger
from services.user_service import UserService
from services.hashtag_service import HashtagService


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Liker des posts Instagram")
    parser.add_argument("username", help="Nom d'utilisateur Instagram")
    parser.add_argument("password", help="Mot de passe Instagram")
    parser.add_argument("--mode", choices=["user", "hashtag", "random"], required=True,
                       help="Mode de like (user, hashtag, random)")
    parser.add_argument("--target", required=True,
                       help="Cible: username pour user, hashtag pour hashtag, user_id ou media_ids pour random")
    parser.add_argument("--count", type=int, default=5,
                       help="Nombre de posts à liker (défaut: 5)")
    parser.add_argument("--hashtag-action", choices=["recent", "top"], default="recent",
                       help="Action pour les hashtags (défaut: recent)")
    parser.add_argument("--cursor", help="Curseur pour la pagination")
    parser.add_argument("--log-dir", default="logs",
                       help="Répertoire de logs (défaut: logs)")

    args = parser.parse_args()

    try:
        # Initialiser le client et le logger
        client = InstagramClient(args.username, args.password)
        logger = InstagramLogger(args.username, args.log_dir)

        # Initialiser les services
        user_service = UserService(client, logger)
        hashtag_service = HashtagService(client, logger)

        # Exécuter selon le mode
        if args.mode == "user":
            result = user_service.like_user_posts(args.target, args.count)
        elif args.mode == "hashtag":
            result = hashtag_service.like_hashtag_posts(
                args.target, args.count, args.hashtag_action, args.cursor
            )
        elif args.mode == "random":
            # Détecter automatiquement le type de target
            if args.target.isdigit():
                # C'est un user_id
                target = args.target
            elif args.target.startswith('['):
                # C'est un JSON array
                try:
                    target = json.loads(args.target)
                except json.JSONDecodeError:
                    raise ValueError("Format JSON invalide pour target")
            else:
                raise ValueError("Pour le mode random, target doit être un user_id ou un JSON array")

            result = user_service.like_random_posts(target, args.count)

        # Ajouter l'horodatage
        result["timestamp"] = client.get_current_timestamp()

        # Afficher le résultat
        client.print_json_result(result)

        # Afficher le résumé des logs sur stderr pour éviter de polluer stdout
        logger.print_summary_to_stderr()

    except Exception as e:
        print(f'{{"error": "{str(e)}"}}')
        sys.exit(1)


if __name__ == "__main__":
    main()
