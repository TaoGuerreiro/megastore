#!/usr/bin/env python3
# frozen_string_literal: true
"""
Script d'engagement Instagram unifié (refonte comportement humain)
"""

import sys
import json
import argparse
import random
import time
import os
import requests
from datetime import datetime, timedelta, time as dtime
from collections import defaultdict
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from core import InstagramClient, InstagramLogger, ConfigLoader, ErrorHandler
from services.hashtag_service import HashtagService
from services.user_service import UserService
from services.message_service import MessageService


def handle_error(error_message: str):
    """Gestion d'erreur standardisée"""
    ErrorHandler.handle_error(error_message)


class EngagementService:
    """Service d'engagement Instagram avec comportement humain réaliste"""

    def __init__(self, config_file_path, campagne_id=None):
        self.config_file_path = config_file_path
        self.campagne_id = campagne_id
        self.start_time = datetime.now()
        self.config = self.load_config()
        self.stats_dir = os.path.join(os.path.dirname(__file__), "..", "..", "stats")
        os.makedirs(self.stats_dir, exist_ok=True)
        self.api_base_url = "http://localhost:3000"
        self.api_token = os.getenv("SOCIAL_CAMPAIGN_API_TOKEN", "azerty")
        self.session_results = []

    def load_config(self):
        try:
            return ConfigLoader.load_from_file(self.config_file_path)
        except Exception as e:
            raise Exception(f"Erreur lors du chargement de la configuration: {e}")

    def update_social_target_stats(self, social_campagne_id, social_target_id, post_id):
        try:
            url = f"{self.api_base_url}/api/social_campagnes/{social_campagne_id}/social_targets/{social_target_id}/like"
            headers = {
                "Authorization": f"Bearer {self.api_token}",
                "Content-Type": "application/json"
            }
            data = {"post_id": post_id}
            response = requests.post(url, headers=headers, json=data, timeout=10)
            return response.status_code == 200
        except Exception:
            return False

    def update_hashtag_cursor_on_rails(self, social_campagne_id, social_target_id, cursor):
        # Met à jour le cursor sur l'objet social_target via l'API Rails
        try:
            url = f"{self.api_base_url}/api/social_campagnes/{social_campagne_id}/social_targets/{social_target_id}"
            headers = {
                "Authorization": f"Bearer {self.api_token}",
                "Content-Type": "application/json"
            }
            payload = {"cursor": cursor}
            response = requests.patch(url, headers=headers, json=payload, timeout=5)
            if response.status_code != 200:
                print(f"[WARNING] Erreur mise à jour cursor: {response.status_code}")
        except Exception as e:
            print(f"[WARNING] Erreur mise à jour cursor: {e}")
            pass  # On ignore les erreurs pour ne pas bloquer le process

    def get_state_path(self, username):
        return os.path.join(self.stats_dir, f"engagement_state_{username}.json")

    def save_state(self, username, state):
        with open(self.get_state_path(username), 'w', encoding='utf-8') as f:
            json.dump(state, f, ensure_ascii=False, indent=2, default=str)

    def load_state(self, username):
        path = self.get_state_path(username)
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
        return None

    def random_time_between(self, start_hour, end_hour):
        h = random.randint(start_hour, end_hour-1)
        m = random.randint(0, 59)
        return dtime(hour=h, minute=m)

    def random_likes_distribution(self, total_likes, hours_count, max_per_hour=25):
        # Génère une répartition aléatoire non constante, max par heure
        likes = [1]*hours_count
        for _ in range(total_likes-hours_count):
            idx = random.randint(0, hours_count-1)
            if likes[idx] < max_per_hour:
                likes[idx] += 1
        random.shuffle(likes)
        return likes

    def random_split(self, n, ratio=0.5, spread=0.15):
        # Répartition aléatoire autour d'un ratio (ex: 0.5)
        r = random.uniform(ratio-spread, ratio+spread)
        n1 = int(n*r)
        n2 = n-n1
        return n1, n2

    def wait_until(self, target_time):
        now = datetime.now()
        target = now.replace(hour=target_time.hour, minute=target_time.minute, second=0, microsecond=0)
        if now > target:
            target += timedelta(days=1)
        wait_s = (target - now).total_seconds()
        if wait_s > 0:
            print(f"[WAIT] Attente jusqu'à {target_time.strftime('%H:%M')} ({int(wait_s//60)} min)")
            time.sleep(wait_s)

    def get_log_path(self, username):
        return os.path.join(self.stats_dir, f"engagement_log_{username}.jsonl")

    def log_event(self, username, event_type, **kwargs):
        log_path = self.get_log_path(username)
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "event": event_type,
            **kwargs
        }
        with open(log_path, 'a', encoding='utf-8') as f:
            f.write(json.dumps(log_entry, ensure_ascii=False) + "\n")
        # Envoi à l'API Rails si social_campagne_id présent
        social_campagne_id = None
        # Chercher dans kwargs ou dans payload
        if "social_campagne_id" in kwargs:
            social_campagne_id = kwargs["social_campagne_id"]
        elif "payload" in kwargs and isinstance(kwargs["payload"], dict):
            social_campagne_id = kwargs["payload"].get("social_campagne_id")
        # Si trouvé, envoyer le log
        if social_campagne_id:
            try:
                url = f"{self.api_base_url}/api/social_campagnes/{social_campagne_id}/logs"
                headers = {
                    "Authorization": f"Bearer {self.api_token}",
                    "Content-Type": "application/json"
                }
                payload = {
                    "event": event_type,
                    "timestamp": log_entry["timestamp"],
                    "payload": {k: v for k, v in kwargs.items() if k != "social_campagne_id"}
                }
                requests.post(url, headers=headers, json=payload, timeout=5)
            except Exception as e:
                # On log juste l'erreur localement, mais on ne bloque pas le process
                with open(log_path, 'a', encoding='utf-8') as f:
                    f.write(json.dumps({
                        "timestamp": datetime.now().isoformat(),
                        "event": "log_api_error",
                        "error": str(e)
                    }) + "\n")

    def get_campaign_status(self, social_campagne_id):
        try:
            url = f"{self.api_base_url}/api/social_campagnes/{social_campagne_id}/status"
            headers = {
                "Authorization": f"Bearer {self.api_token}",
                "Content-Type": "application/json"
            }
            resp = requests.get(url, headers=headers, timeout=5)
            if resp.status_code == 200:
                return resp.json().get("status")
        except Exception as e:
            pass  # En cas d'erreur réseau, on continue (fail open)
        return None

    def _prepare_challenge_config(self, account_config):
        """
        Préparer la configuration de challenge pour un compte

        Args:
            account_config: Configuration du compte Instagram

        Returns:
            Configuration de challenge ou None
        """
        # Utiliser ConfigLoader pour extraire la configuration de challenge
        return ConfigLoader.get_challenge_config(account_config)

    def fetch_followers_for_targets(self, user_service, targeted_accounts, n_needed, state, username):
        # Pour chaque targeted_account, récupérer le batch de followers nécessaire (avec cursor)
        followers_by_account = {}
        cursors = state.get("targeted_cursors", {})
        for account in targeted_accounts:
            acc_name = account.get("account") if isinstance(account, dict) else account
            acc_id = account.get("social_target_id") if isinstance(account, dict) else None
            acc_cursor = cursors.get(acc_name)
            followers = []
            batch_size = n_needed.get(acc_name, 0)
            if batch_size == 0:
                continue
            try:
                result = user_service.get_user_followers(acc_name, limit=batch_size, cursor=acc_cursor)
                followers = result["followers"]
                new_cursor = result.get("cursor")
                cursors[acc_name] = new_cursor
                # TODO: envoyer le cursor à l'API Rails si acc_id
                # (à faire via une requête PATCH sur le social_target)
            except Exception as e:
                self.log_event(username, "fetch_followers_error", account=acc_name, error=str(e))
            followers_by_account[acc_name] = followers
        state["targeted_cursors"] = cursors
        return followers_by_account, state

    def generate_like_schedule(self, start_time, end_time, total_likes, hashtags, targeted_accounts, user_service, state, username):
        # Répartition aléatoire hashtag/target
        ratio = random.uniform(0.45, 0.55)
        n_hashtag = int(total_likes * ratio)
        n_target = total_likes - n_hashtag
        # Répartition équitable des likes target entre comptes cibles
        n_targets_per_account = {}
        if targeted_accounts:
            for i, account in enumerate(targeted_accounts):
                acc_name = account.get("account") if isinstance(account, dict) else account
                n_targets_per_account[acc_name] = n_target // len(targeted_accounts)
            # Répartir le reste
            for i in range(n_target % len(targeted_accounts)):
                acc_name = targeted_accounts[i].get("account") if isinstance(targeted_accounts[i], dict) else targeted_accounts[i]
                n_targets_per_account[acc_name] += 1
        # Pour chaque targeted_account, déterminer le nombre de followers nécessaires
        n_followers_needed = {}
        posts_per_follower = {}
        for acc_name, n_likes in n_targets_per_account.items():
            # On tire au sort pour chaque follower le nombre de posts à liker (2 à 5)
            n = 0
            posts_list = []
            while n < n_likes:
                n_posts = random.randint(2, 5)
                posts_list.append(n_posts)
                n += n_posts
            # On ajuste le dernier pour ne pas dépasser
            if n > n_likes:
                posts_list[-1] -= (n - n_likes)
            n_followers_needed[acc_name] = len(posts_list)
            posts_per_follower[acc_name] = posts_list
        # Récupérer les followers nécessaires (avec gestion du cursor)
        followers_by_account, state = self.fetch_followers_for_targets(user_service, targeted_accounts, n_followers_needed, state, username)
        # Générer la trame
        start_dt = datetime.combine(datetime.today(), start_time)
        end_dt = datetime.combine(datetime.today(), end_time)
        total_seconds = int((end_dt - start_dt).total_seconds())
        like_seconds = sorted(random.sample(range(total_seconds), total_likes))
        like_times = [start_dt + timedelta(seconds=s) for s in like_seconds]
        # Générer la liste des actions (hashtag/target)
        like_types = ["hashtag"] * n_hashtag + ["target"] * n_target
        random.shuffle(like_types)
        # Préparer la liste des followers à utiliser pour chaque targeted_account
        follower_indices = {acc_name: 0 for acc_name in n_targets_per_account}
        follower_post_indices = {acc_name: 0 for acc_name in n_targets_per_account}
        schedule = []
        for like_type in like_types:
            if like_type == "hashtag" or not targeted_accounts:
                cible = random.choice(hashtags) if hashtags else None
                schedule.append({
                    "time": like_times.pop(0).isoformat(),
                    "type": "hashtag",
                    "cible": cible
                })
            else:
                # Choisir le compte cible de façon équitable
                acc_name = min(follower_indices, key=lambda k: follower_indices[k])
                followers = followers_by_account.get(acc_name, [])
                if not followers:
                    # fallback : on saute ce like target
                    continue
                follower_idx = follower_indices[acc_name]
                if follower_idx >= len(followers):
                    continue
                follower = followers[follower_idx]
                n_posts = posts_per_follower[acc_name][follower_idx]
                # Correction : convertir le follower en dict standard
                if hasattr(follower, '__dict__'):
                    follower_dict = {k: v for k, v in follower.__dict__.items() if k in ["username", "user_id", "full_name", "is_private", "is_verified", "profile_pic_url"]}
                elif isinstance(follower, dict):
                    follower_dict = {k: v for k, v in follower.items() if k in ["username", "user_id", "full_name", "is_private", "is_verified", "profile_pic_url"]}
                else:
                    follower_dict = {"username": str(follower)}
                schedule.append({
                    "time": like_times.pop(0).isoformat(),
                    "type": "target",
                    "targeted_account": acc_name,
                    "follower": follower_dict,
                    "n_posts": n_posts
                })
                follower_indices[acc_name] += 1
        return schedule, state

    def run_engagement(self):
        print(json.dumps({
            "status": "started",
            "message": f"Démarrage de l'engagement pour {len(self.config)} comptes",
            "timestamp": self.start_time.isoformat()
        }))
        for account_config in self.config:
            result = self.run_account_engagement(account_config)
            self.session_results.append(result)
        final_report = self.generate_final_report()
        print(json.dumps(final_report))
        return final_report

    def run_account_engagement(self, account_config):
        username = account_config["username"]
        password = account_config["password"]
        hashtags = account_config.get("hashtags", [])
        targeted_accounts = account_config.get("targeted_accounts", [])
        state = self.load_state(username) or {}
        # Récupérer le social_campagne_id pour tous les logs
        scid_global = account_config.get("social_campagne_id")
        # 1. Définir la plage horaire
        if not state.get("start_hour"):
            # start_time = self.random_time_between(6, 8)
            start_time = datetime.now().time()
            # end_time = self.random_time_between(18, 21)
            end_time = dtime(hour=23, minute=59)
            while end_time <= start_time:
                end_time = self.random_time_between(18, 21)
            state["start_hour"] = start_time.strftime("%H:%M")
            state["end_hour"] = end_time.strftime("%H:%M")
        else:
            start_time = dtime.fromisoformat(state["start_hour"])
            end_time = dtime.fromisoformat(state["end_hour"])
        self.log_event(username, "session_start", start_hour=start_time.strftime("%H:%M"), end_hour=end_time.strftime("%H:%M"), social_campagne_id=scid_global)
        now = datetime.now().time()
        if now < start_time:
            self.log_event(username, "wait_before_start", wait_until=start_time.strftime("%H:%M"), social_campagne_id=scid_global)
            self.wait_until(start_time)
        elif now > end_time:
            self.log_event(username, "skipped_out_of_time", now=now.strftime("%H:%M"), social_campagne_id=scid_global)
            print(f"[INFO] Plage horaire dépassée pour {username}, arrêt.")
            return {"username": username, "status": "skipped", "reason": "out_of_time"}
        # 2. Likes à faire
        if not state.get("total_likes"):
            total_likes = random.randint(150, 200)
            state["total_likes"] = total_likes
        else:
            total_likes = state["total_likes"]
        # 3. Préparer la configuration de challenge
        challenge_config = self._prepare_challenge_config(account_config)

        # 4. Générer ou charger la trame globale
        client = InstagramClient(username, password, challenge_config=challenge_config)
        logger = InstagramLogger(username)
        hashtag_service = HashtagService(client, logger)
        user_service = UserService(client, logger)
        if not state.get("like_schedule"):
            schedule, state = self.generate_like_schedule(start_time, end_time, total_likes, hashtags, targeted_accounts, user_service, state, username)
            state["like_schedule"] = schedule
            state["like_index"] = 0
            self.save_state(username, state)
        else:
            schedule = state["like_schedule"]
        like_index = state.get("like_index", 0)
        # 4. Boucle sur la trame
        if not state.get("hashtag_cursors"):
            state["hashtag_cursors"] = {}
        hashtag_cursors = state["hashtag_cursors"]
        for i in range(like_index, len(schedule)):
            item = schedule[i]
            like_time = datetime.fromisoformat(item["time"])
            now = datetime.now()
            if now < like_time:
                wait_s = (like_time - now).total_seconds()
                self.log_event(username, "wait_like", wait_until=like_time.isoformat(), seconds=int(wait_s), social_campagne_id=scid_global)
                time.sleep(wait_s)
            scid = None
            if item["type"] == "hashtag":
                cible = item["cible"]
                hashtag_name = cible.get("hashtag") if isinstance(cible, dict) else cible
                social_target_id = cible.get("social_target_id") if isinstance(cible, dict) else None
                if isinstance(cible, dict):
                    scid = cible.get("social_campagne_id")
                if not scid and "social_campagne_id" in account_config:
                    scid = account_config["social_campagne_id"]
                if scid:
                    status = self.get_campaign_status(scid)
                    if status == "paused":
                        self.log_event(username, "campaign_paused", social_campagne_id=scid)
                        state["like_index"] = i
                        self.save_state(username, state)
                        return {"username": username, "status": "paused", "reason": "campaign_paused"}
                # Gestion du cursor pour le hashtag
                cursor = hashtag_cursors.get(hashtag_name)

                # Vérifier si on a déjà atteint la fin de l'historique pour ce hashtag
                if hashtag_cursors.get(f"{hashtag_name}_end_of_history"):
                    self.log_event(username, "hashtag_skip_end_of_history", hashtag=hashtag_name, social_campagne_id=scid_global)
                    continue

                try:
                    result = hashtag_service.get_hashtag_posts(hashtag_name, action="recent", amount=10, cursor=cursor)
                    posts = result["posts"]
                    next_cursor = result.get("next_cursor")
                    has_more = result.get("has_more")

                    # Log pour tracer les curseurs
                    self.log_event(username, "hashtag_cursor_debug",
                                 hashtag=hashtag_name,
                                 current_cursor=cursor,
                                 next_cursor=next_cursor,
                                 has_more=has_more,
                                 posts_count=len(posts),
                                 social_campagne_id=scid_global)

                    # Filtrer les posts non likés
                    available_posts = [post for post in posts if not post.has_liked]
                    if not available_posts:
                        self.log_event(username, "no_post_to_like", hashtag=hashtag_name, cursor=cursor, social_campagne_id=scid_global)
                    else:
                        post = available_posts[0]
                        # Like le post
                        try:
                            hashtag_service.client.client.media_like(post.media_id)
                            self.log_event(username, "like_hashtag", hashtag=hashtag_name, post_id=post.media_id, status="success", social_campagne_id=scid)
                            if social_target_id and scid:
                                self.update_social_target_stats(scid, social_target_id, post.media_id)
                        except Exception as e:
                            self.log_event(username, "like_hashtag", hashtag=hashtag_name, post_id=post.media_id, error=str(e), status="error", social_campagne_id=scid)
                        # Mettre à jour le cursor
                        hashtag_cursors[hashtag_name] = next_cursor
                        state["hashtag_cursors"] = hashtag_cursors
                        self.save_state(username, state)
                        # Synchroniser le cursor sur Rails
                        if social_target_id and next_cursor:
                            self.update_hashtag_cursor_on_rails(scid, social_target_id, next_cursor)

                    # Si plus de posts à liker, marquer la fin de l'historique
                    if not has_more:
                        self.log_event(username, "hashtag_end_of_history", hashtag=hashtag_name, social_campagne_id=scid_global)
                        hashtag_cursors[f"{hashtag_name}_end_of_history"] = True
                        state["hashtag_cursors"] = hashtag_cursors
                        self.save_state(username, state)

                except Exception as e:
                    self.log_event(username, "hashtag_error", hashtag=hashtag_name, error=str(e), social_campagne_id=scid)
                    print(f'{{"error": "Hashtag {hashtag_name}: {e}"}}')
            elif item["type"] == "target":
                targeted_account = item["targeted_account"]
                follower = item["follower"]
                n_posts = item["n_posts"]
                scid = None
                if isinstance(follower, dict):
                    scid = follower.get("social_campagne_id")
                if not scid and "social_campagne_id" in account_config:
                    scid = account_config["social_campagne_id"]
                if scid:
                    status = self.get_campaign_status(scid)
                    if status == "paused":
                        self.log_event(username, "campaign_paused", social_campagne_id=scid)
                        state["like_index"] = i
                        self.save_state(username, state)
                        return {"username": username, "status": "paused", "reason": "campaign_paused"}
                try:
                    if isinstance(follower, dict) and "username" in follower:
                        follower_username = follower["username"]
                    else:
                        self.log_event(username, "like_follower_post", targeted_account=targeted_account, follower=str(follower), error="Follower sans username", status="error", social_campagne_id=scid)
                        continue
                    result = user_service.like_user_posts(follower_username, count=n_posts)
                    liked_posts = result.get("liked_posts", [])
                    for post in liked_posts:
                        self.log_event(username, "like_follower_post", targeted_account=targeted_account, follower=follower_username, post_id=post.get("media_id"), status="success", social_campagne_id=scid)
                except Exception as e:
                    self.log_event(username, "like_follower_post", targeted_account=targeted_account, follower=follower.get("username", str(follower)), error=str(e), status="error", social_campagne_id=scid)
                    print(f'{{"error": "Like follower post: {e}"}}')
            state["like_index"] = i + 1
            self.save_state(username, state)
        self.log_event(username, "session_end", social_campagne_id=scid_global)
        return {"username": username, "status": "completed"}

    def generate_final_report(self):
        end_time = datetime.now()
        return {
            "status": "completed",
            "session_start": self.start_time.isoformat(),
            "session_end": end_time.isoformat(),
            "total_accounts": len(self.config),
            "sessions": self.session_results,
            "campagne_id": self.campagne_id
        }


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Script d'engagement Instagram unifié")

    # Arguments de configuration (fichier de config en premier argument positionnel)
    parser.add_argument("config_file", help="Fichier de configuration JSON")

    # Arguments optionnels
    parser.add_argument(
        "--campagne-id",
        type=int,
        help="ID de la campagne sociale"
    )
    parser.add_argument(
        "--log-dir",
        default="logs",
        help="Répertoire de logs (défaut: logs)"
    )

    args = parser.parse_args()

    try:
        # Initialiser le service d'engagement
        engagement_service = EngagementService(args.config_file, args.campagne_id)

        # Exécuter l'engagement
        result = engagement_service.run_engagement()

        # Afficher le résultat final
        print(json.dumps(result, ensure_ascii=False, indent=2))

    except Exception as e:
        ErrorHandler.handle_error(str(e))


if __name__ == "__main__":
    main()
