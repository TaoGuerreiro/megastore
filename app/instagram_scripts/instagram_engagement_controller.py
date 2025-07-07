import sys
import json
import random
import time
import os
import requests
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor, as_completed
from base_instagram_client import BaseInstagramClient

API_URL = os.environ.get("SOCIAL_CAMPAIGN_API_URL", "http://localhost:3000")
API_TOKEN = os.environ.get("SOCIAL_CAMPAIGN_API_TOKEN")

class InstagramEngagementController:
    def __init__(self, accounts_config, campagne_id=None):
        """
        Controller pour l'engagement Instagram automatisé

        Args:
            accounts_config: Liste de dictionnaires avec username, password, hashtags, targeted_accounts
            campagne_id: ID de la campagne (optionnel)
        """
        self.accounts_config = accounts_config
        self.session_logs = []
        self.start_time = datetime.now()
        self.campagne_id = campagne_id or os.environ.get("SOCIAL_CAMPAIGN_ID")

        # Créer le dossier stats s'il n'existe pas
        self.stats_dir = os.path.join(os.path.dirname(__file__), "..", "..", "stats")
        os.makedirs(self.stats_dir, exist_ok=True)

        # Créer le fichier de logs avec timestamp
        timestamp = self.start_time.strftime("%Y%m%d_%H%M%S")
        self.log_file_path = os.path.join(self.stats_dir, f"engagement_logs_{timestamp}.json")

        # Initialiser le fichier de logs
        self.init_log_file()

    def init_log_file(self):
        """Initialiser le fichier de logs avec la structure de base"""
        log_data = {
            "session_start": self.start_time.isoformat(),
            "accounts_count": len(self.accounts_config),
            "accounts": [acc["username"] for acc in self.accounts_config],
            "logs": [],
            "sessions": []
        }

        with open(self.log_file_path, 'w', encoding='utf-8') as f:
            json.dump(log_data, f, indent=2, ensure_ascii=False)

    def append_log(self, log_entry):
        """Ajouter un log au fichier JSON"""
        try:
            # Lire le fichier existant
            with open(self.log_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Ajouter le nouveau log
            data["logs"].append(log_entry)

            # Réécrire le fichier
            with open(self.log_file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)

        except Exception as e:
            # En cas d'erreur, afficher le log sur stdout
            print(json.dumps(log_entry))

    def update_sessions(self, session_log):
        """Mettre à jour les sessions dans le fichier de logs"""
        try:
            # Lire le fichier existant
            with open(self.log_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Ajouter ou mettre à jour la session
            session_updated = False
            for i, existing_session in enumerate(data["sessions"]):
                if existing_session.get("username") == session_log["username"]:
                    data["sessions"][i] = session_log
                    session_updated = True
                    break

            if not session_updated:
                data["sessions"].append(session_log)

            # Réécrire le fichier
            with open(self.log_file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)

        except Exception as e:
            # En cas d'erreur, afficher sur stdout
            print(json.dumps({"error": f"Erreur mise à jour sessions: {str(e)}"}))

    def run_engagement_sessions(self):
        """Lancer les sessions d'engagement pour tous les comptes en parallèle"""
        try:
            self.log_info(f"Démarrage des sessions d'engagement pour {len(self.accounts_config)} comptes")
            self.log_info(f"Dossier de logs: {self.stats_dir}")

            # Lancer les sessions en parallèle
            with ThreadPoolExecutor(max_workers=len(self.accounts_config)) as executor:
                futures = []
                for account in self.accounts_config:
                    future = executor.submit(self.run_single_session_with_individual_log, account)
                    futures.append(future)

                # Attendre que toutes les sessions se terminent
                for future in as_completed(futures):
                    try:
                        result = future.result()
                        self.session_logs.append(result)
                    except Exception as e:
                        self.log_error(f"Erreur dans une session: {str(e)}")

            # Afficher le rapport final
            self.print_final_report()

        except Exception as e:
            self.log_error(f"Erreur générale: {str(e)}")

    def run_single_session_with_individual_log(self, account_config):
        """Exécuter une session d'engagement pour un compte avec log individuel"""
        username = account_config["username"]
        timestamp = self.start_time.strftime("%Y%m%d_%H%M%S")
        log_file_path = os.path.join(self.stats_dir, f"engagement_logs_{username}_{timestamp}.json")

        # Initialiser le fichier de log individuel
        self.init_individual_log_file(log_file_path, username, account_config)

        # Passer le chemin du log à la session
        return self.run_single_session(account_config, log_file_path)

    def init_individual_log_file(self, log_file_path, username, account_config):
        """Initialiser le fichier de log individuel avec stats vides"""
        # Extraire les hashtags et comptes ciblés avec leurs cursors
        hashtags_with_cursors = []
        targeted_accounts_with_cursors = []

        # Traiter les hashtags
        hashtags_raw = account_config.get("hashtags", [])
        for entry in hashtags_raw:
            if isinstance(entry, dict):
                hashtags_with_cursors.append({
                    "hashtag": entry["hashtag"],
                    "cursor": entry.get("cursor"),
                    "stats": {
                        "total_likes": 0,
                        "posts_liked": [],
                        "last_activity": None
                    }
                })
            else:
                hashtags_with_cursors.append({
                    "hashtag": entry,
                    "cursor": None,
                    "stats": {
                        "total_likes": 0,
                        "posts_liked": [],
                        "last_activity": None
                    }
                })

        # Traiter les comptes ciblés
        targeted_accounts_raw = account_config.get("targeted_accounts", [])
        for entry in targeted_accounts_raw:
            if isinstance(entry, dict):
                targeted_accounts_with_cursors.append({
                    "account": entry["account"],
                    "cursor": entry.get("cursor"),
                    "stats": {
                        "total_likes": 0,
                        "followers_processed": 0,
                        "posts_liked": [],
                        "last_activity": None
                    }
                })
            else:
                targeted_accounts_with_cursors.append({
                    "account": entry,
                    "cursor": None,
                    "stats": {
                        "total_likes": 0,
                        "followers_processed": 0,
                        "posts_liked": [],
                        "last_activity": None
                    }
                })

        log_data = {
            "session_start": self.start_time.isoformat(),
            "username": username,
            "hashtags": hashtags_with_cursors,
            "targeted_accounts": targeted_accounts_with_cursors,
            "global_stats": {
                "total_likes": 0,
                "total_sessions": 0,
                "last_session": None
            },
            "logs": [],
            "sessions": []
        }
        with open(log_file_path, 'w', encoding='utf-8') as f:
            json.dump(log_data, f, indent=2, ensure_ascii=False)

    def update_individual_cursors(self, log_file_path, hashtag_cursors, follower_cursors):
        """Mettre à jour les cursors dans le fichier de log individuel"""
        try:
            with open(log_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Mettre à jour les cursors des hashtags
            for hashtag_entry in data["hashtags"]:
                if hashtag_entry["hashtag"] in hashtag_cursors:
                    hashtag_entry["cursor"] = hashtag_cursors[hashtag_entry["hashtag"]]

            # Mettre à jour les cursors des comptes ciblés
            for account_entry in data["targeted_accounts"]:
                if account_entry["account"] in follower_cursors:
                    account_entry["cursor"] = follower_cursors[account_entry["account"]]

            with open(log_file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)

        except Exception as e:
            print(json.dumps({"error": f"Erreur update_individual_cursors: {str(e)}"}))

    def update_individual_stats(self, log_file_path, stat_type, key, increment=1, post_id=None):
        """Mettre à jour les stats en temps réel dans le fichier de log individuel"""
        try:
            with open(log_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Mettre à jour les stats globales
            data["global_stats"]["total_likes"] += increment

            # Mettre à jour les stats spécifiques
            if stat_type == "hashtag":
                for hashtag_entry in data["hashtags"]:
                    if hashtag_entry["hashtag"] == key:
                        hashtag_entry["stats"]["total_likes"] += increment
                        if post_id:
                            hashtag_entry["stats"]["posts_liked"].append(str(post_id))
                        hashtag_entry["stats"]["last_activity"] = datetime.now().isoformat()
                        break
            elif stat_type == "follower":
                for account_entry in data["targeted_accounts"]:
                    if account_entry["account"] == key:
                        account_entry["stats"]["total_likes"] += increment
                        if post_id:
                            account_entry["stats"]["posts_liked"].append(str(post_id))
                        account_entry["stats"]["last_activity"] = datetime.now().isoformat()
                        break

            with open(log_file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(json.dumps({"error": f"Erreur update_individual_stats: {str(e)}"}))

    def update_follower_stats(self, log_file_path, target_account, followers_processed):
        """Mettre à jour les statistiques des followers traités"""
        try:
            with open(log_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            for account_entry in data["targeted_accounts"]:
                if account_entry["account"] == target_account:
                    account_entry["stats"]["followers_processed"] += followers_processed
                    account_entry["stats"]["last_activity"] = datetime.now().isoformat()
                    break

            with open(log_file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(json.dumps({"error": f"Erreur update_follower_stats: {str(e)}"}))

    def run_single_session(self, account_config, log_file_path=None):
        """Exécuter une session d'engagement pour un compte"""
        session_log = {
            "username": account_config["username"],
            "session_start": None,
            "session_end": None,
            "total_likes": 0,
            "hashtag_likes": {},
            "follower_likes": {},
            "errors": [],
            "status": "completed"
        }

        try:
            self.log_info(f"Démarrage session pour {account_config['username']}", log_file_path)

            # Initialiser le client Instagram
            client = BaseInstagramClient(account_config["username"], account_config["password"])

            # Calculer le timing de la session
            session_start, session_end = self.calculate_session_timing()
            session_log["session_start"] = session_start.isoformat()
            session_log["session_end"] = session_end.isoformat()

            self.log_info(f"Session {account_config['username']}: {session_start.strftime('%H:%M')} - {session_end.strftime('%H:%M')}", log_file_path)

            # Attendre jusqu'au début de la session
            self.wait_until(session_start, log_file_path)

            # Calculer la durée de la session en secondes
            session_duration_seconds = max(1, int((session_end - session_start).total_seconds()))

            # Tirer la limite jour et la limite heure
            likes_max_jour = random.randint(150, 200)
            likes_max_heure = random.randint(20, 30)
            session_log["likes_max_jour"] = likes_max_jour
            session_log["likes_max_heure"] = likes_max_heure
            session_log["session_duration_seconds"] = session_duration_seconds

            # Calculer le nombre total de likes à planifier
            total_likes = min(likes_max_jour, likes_max_heure * session_duration_seconds)
            session_log["total_likes"] = total_likes

            # Calculer l'intervalle moyen entre chaque like
            if total_likes > 0:
                mean_interval = session_duration_seconds / total_likes
            else:
                mean_interval = 60  # fallback
            session_log["mean_interval_seconds"] = mean_interval

            # Adapter la récupération des comptes cibles et des cursors
            targeted_accounts_raw = account_config.get("targeted_accounts", [])
            targeted_accounts = []
            targeted_cursors = {}
            for entry in targeted_accounts_raw:
                if isinstance(entry, dict):
                    targeted_accounts.append(entry["account"])
                    if "cursor" in entry:
                        targeted_cursors[entry["account"]] = entry["cursor"]
                else:
                    targeted_accounts.append(entry)

            # Adapter la récupération des hashtags et des cursors
            hashtags_raw = account_config.get("hashtags", [])
            hashtags = []
            hashtag_cursors = {}
            for entry in hashtags_raw:
                if isinstance(entry, dict):
                    hashtags.append(entry["hashtag"])
                    if "cursor" in entry:
                        hashtag_cursors[entry["hashtag"]] = entry["cursor"]
                else:
                    hashtags.append(entry)

            # Répartition des likes
            hashtag_likes, follower_likes = self.calculate_likes_distribution(
                total_likes,
                hashtags,
                targeted_accounts
            )

            session_log["planned_hashtag_likes"] = hashtag_likes
            session_log["planned_follower_likes"] = follower_likes

            self.log_info(f"Session {account_config['username']}: {total_likes} likes planifiés (max {likes_max_heure}/h, max {likes_max_jour}/jour sur {session_duration_seconds}s)", log_file_path)

            # Exécuter les likes sur les hashtags
            likes_done = self.execute_hashtag_likes_with_limit(client, hashtag_likes, session_log, session_end, account_config["username"], total_likes, log_file_path, mean_interval, hashtag_cursors)

            # Exécuter les likes sur les followers si quota non atteint
            if likes_done < total_likes:
                self.execute_follower_likes_with_limit(client, follower_likes, session_log, session_end, account_config["username"], total_likes, likes_done, log_file_path, mean_interval, targeted_cursors)

            # Mettre à jour les cursors dans le fichier de log individuel
            if log_file_path:
                hashtag_cursors_updated = {}
                follower_cursors_updated = {}

                # Extraire les nouveaux cursors des hashtags
                for hashtag, data in session_log.get("hashtag_likes", {}).items():
                    if "cursor" in data:
                        hashtag_cursors_updated[hashtag] = data["cursor"]

                # Extraire les nouveaux cursors des followers
                for account, data in session_log.get("follower_likes", {}).items():
                    if "cursor" in data:
                        follower_cursors_updated[account] = data["cursor"]

                self.update_individual_cursors(log_file_path, hashtag_cursors_updated, follower_cursors_updated)

                # Mettre à jour les statistiques globales
                self.update_global_stats(log_file_path, session_log)

            session_log["status"] = "completed"
            self.log_info(f"Session {account_config['username']} terminée avec succès", log_file_path)

        except Exception as e:
            session_log["status"] = "error"
            session_log["errors"].append(str(e))
            self.log_error(f"Erreur session {account_config['username']}: {str(e)}", log_file_path)

        return session_log

    def calculate_session_timing(self):
        """Calculer le timing aléatoire de la session"""
        # Début entre 8h et 10h
        start_hour = 11
        start_minute = 10
        start_time = datetime.now().replace(hour=start_hour, minute=start_minute, second=0, microsecond=0)

        # Si l'heure de début est déjà passée aujourd'hui, programmer pour demain
        if start_time <= datetime.now():
            start_time += timedelta(days=1)

        # Fin entre 21h et 23h le même jour
        end_hour = random.randint(21, 22)
        end_minute = random.randint(0, 59)
        end_time = start_time.replace(hour=end_hour, minute=end_minute, second=0, microsecond=0)

        # Si la fin est avant le début, ajuster
        if end_time <= start_time:
            end_time = start_time.replace(hour=random.randint(10, 12), minute=random.randint(0, 59))

        return start_time, end_time

    def calculate_likes_distribution(self, total_likes, hashtags, targeted_accounts):
        """Calculer la répartition aléatoire des likes"""
        # Répartition entre hashtags et followers (60% hashtags, 40% followers)
        hashtag_total = int(total_likes * 0.6)
        follower_total = total_likes - hashtag_total

        # Répartition des likes par hashtag
        hashtag_likes = {}
        if hashtags:
            remaining_hashtag_likes = hashtag_total
            for i, hashtag in enumerate(hashtags):
                if i == len(hashtags) - 1:
                    # Dernier hashtag : prendre le reste
                    hashtag_likes[hashtag] = remaining_hashtag_likes
                else:
                    # Répartition aléatoire
                    max_likes = remaining_hashtag_likes - (len(hashtags) - i - 1)
                    likes = random.randint(1, max_likes) if max_likes > 0 else 1
                    hashtag_likes[hashtag] = likes
                    remaining_hashtag_likes -= likes

        # Répartition des likes par compte cible (2 likes par follower)
        follower_likes = {}
        if targeted_accounts:
            remaining_follower_likes = follower_total
            for i, account in enumerate(targeted_accounts):
                if i == len(targeted_accounts) - 1:
                    # Dernier compte : prendre le reste
                    follower_likes[account] = remaining_follower_likes
                else:
                    # Répartition aléatoire
                    max_likes = remaining_follower_likes - (len(targeted_accounts) - i - 1)
                    likes = random.randint(1, max_likes) if max_likes > 0 else 1
                    follower_likes[account] = likes
                    remaining_follower_likes -= likes

        return hashtag_likes, follower_likes

    def execute_hashtag_likes_with_limit(self, client, hashtag_likes, session_log, session_end, username, total_likes, log_file_path, mean_interval, hashtag_cursors=None):
        """Exécuter les likes sur les hashtags avec respect du quota total"""
        session_log["hashtag_likes"] = {}
        session_log["hashtag_cursors"] = {}
        likes_done = 0
        if hashtag_cursors is None:
            hashtag_cursors = {}
        for hashtag, target_likes in hashtag_likes.items():
            if likes_done >= total_likes:
                break
            try:
                self.log_info(f"Session {username}: Début likes hashtag #{hashtag} ({target_likes} likes)", log_file_path)
                current_cursor = hashtag_cursors.get(hashtag)
                if current_cursor:
                    self.log_info(f"Session {username}: Utilisation du cursor existant pour #{hashtag}", log_file_path)
                medias, next_cursor = client.client.hashtag_medias_v1_chunk(
                    hashtag,
                    max_amount=min(target_likes * 3, 100),
                    tab_key='recent',
                    max_id=current_cursor
                )
                session_log["hashtag_cursors"][hashtag] = {
                    "previous_cursor": current_cursor,
                    "next_cursor": next_cursor,
                    "has_more": bool(next_cursor)
                }
                available_posts = [media for media in medias if not media.has_liked]
                if not available_posts:
                    self.log_error(f"Session {username}: Aucun post disponible pour le hashtag #{hashtag}", log_file_path)
                    continue
                likes_to_do = min(target_likes, len(available_posts), total_likes - likes_done)
                posts_to_like = random.sample(available_posts, likes_to_do)
                successful_likes = 0
                for i, media in enumerate(posts_to_like):
                    if self.is_campaign_paused():
                        self.log_info(f"Session {username}: Campagne en pause, arrêt immédiat.", log_file_path)
                        return likes_done
                    if datetime.now() >= session_end or likes_done >= total_likes:
                        break
                    try:
                        client.client.media_like(media.id)
                        successful_likes += 1
                        likes_done += 1
                        self.log_info(f"Session {username}: Like #{i+1}/{len(posts_to_like)} sur #{hashtag} (post {media.id})", log_file_path)
                        delay = random.uniform(mean_interval * 0.7, mean_interval * 1.3)
                        self.log_info(f"Session {username}: Pause {int(delay)}s avant prochain like (étalement horaire)", log_file_path)
                        time.sleep(delay)
                        self.update_individual_stats(log_file_path, "hashtag", hashtag, 1, media.id)
                    except Exception as e:
                        self.log_error(f"Session {username}: Erreur like hashtag #{hashtag}: {str(e)}", log_file_path)
                        continue
                session_log["hashtag_likes"][hashtag] = {
                    "target": target_likes,
                    "successful": successful_likes,
                    "posts_liked": [str(media.id) for media in posts_to_like[:successful_likes]],
                    "cursor": next_cursor
                }
                self.log_info(f"Session {username}: Fin likes hashtag #{hashtag} ({successful_likes}/{target_likes} réussis)", log_file_path)
                if datetime.now() < session_end and likes_done < total_likes:
                    pause = random.randint(120, 300)
                    self.log_info(f"Session {username}: Pause {pause}s avant prochain hashtag", log_file_path)
                    time.sleep(pause)
            except Exception as e:
                self.log_error(f"Session {username}: Erreur hashtag #{hashtag}: {str(e)}", log_file_path)
                session_log["hashtag_likes"][hashtag] = {"target": target_likes, "successful": 0, "error": str(e)}
        return likes_done

    def execute_follower_likes_with_limit(self, client, follower_likes, session_log, session_end, username, total_likes, likes_done, log_file_path, mean_interval, targeted_cursors):
        """Exécuter les likes sur les followers avec respect du quota total"""
        session_log["follower_likes"] = {}
        session_log["follower_cursors"] = {}
        for target_account, target_likes in follower_likes.items():
            if likes_done >= total_likes:
                break
            try:
                self.log_info(f"Session {username}: Début likes followers de {target_account} ({target_likes} likes)", log_file_path)
                target_user_id = client.get_user_id_from_username(target_account)
                followers_needed = max(1, target_likes // 2)
                followers = []
                end_cursor = targeted_cursors.get(target_account) if targeted_cursors else None

                if end_cursor:
                    self.log_info(f"Session {username}: Utilisation du cursor existant pour {target_account}", log_file_path)

                while len(followers) < followers_needed and datetime.now() < session_end:
                    chunk, end_cursor = client.client.user_followers_gql_chunk(
                        target_user_id,
                        max_amount=min(50, followers_needed - len(followers)),
                        end_cursor=end_cursor
                    )
                    followers.extend(chunk)
                    if not end_cursor:
                        break
                if not followers:
                    self.log_error(f"Session {username}: Aucun follower trouvé pour {target_account}", log_file_path)
                    continue
                self.log_info(f"Session {username}: {len(followers)} followers récupérés pour {target_account}", log_file_path)
                successful_likes = 0
                for i, follower in enumerate(followers[:followers_needed]):
                    if self.is_campaign_paused():
                        self.log_info(f"Session {username}: Campagne en pause, arrêt immédiat.", log_file_path)
                        return likes_done
                    if datetime.now() >= session_end or likes_done >= total_likes:
                        break
                    try:
                        follower_medias = client.get_user_medias(follower.pk, amount=5)
                        available_posts = [media for media in follower_medias if not media.has_liked]
                        if available_posts:
                            posts_to_like = random.sample(available_posts, min(2, len(available_posts)))
                            for media in posts_to_like:
                                if likes_done >= total_likes or datetime.now() >= session_end:
                                    break
                                client.client.media_like(media.id)
                                successful_likes += 1
                                likes_done += 1
                                self.log_info(f"Session {username}: Like follower {follower.username} ({successful_likes}/{target_likes})", log_file_path)
                                delay = random.uniform(mean_interval * 0.7, mean_interval * 1.3)
                                self.log_info(f"Session {username}: Pause {int(delay)}s avant prochain like (étalement horaire)", log_file_path)
                                time.sleep(delay)
                                self.update_individual_stats(log_file_path, "follower", target_account, 1, media.id)
                                self.update_follower_stats(log_file_path, target_account, 1)
                    except Exception as e:
                        self.log_error(f"Session {username}: Erreur follower {follower.username}: {str(e)}", log_file_path)
                        continue

                # Sauvegarder les informations de cursor
                session_log["follower_cursors"][target_account] = {
                    "previous_cursor": targeted_cursors.get(target_account),
                    "next_cursor": end_cursor,
                    "has_more": bool(end_cursor)
                }

                session_log["follower_likes"][target_account] = {
                    "cursor": end_cursor,
                    "likes": successful_likes,
                    "target": target_likes,
                    "followers_processed": min(followers_needed, len(followers))
                }
                self.log_info(f"Session {username}: Fin likes followers de {target_account} ({successful_likes}/{target_likes} réussis)", log_file_path)
                if datetime.now() < session_end and likes_done < total_likes:
                    pause = random.randint(180, 480)
                    self.log_info(f"Session {username}: Pause {pause}s avant prochain compte cible", log_file_path)
                    time.sleep(pause)
            except Exception as e:
                self.log_error(f"Session {username}: Erreur compte cible {target_account}: {str(e)}", log_file_path)
                session_log["follower_likes"][target_account] = {"cursor": None, "likes": 0, "target": target_likes, "successful": 0, "error": str(e)}

    def wait_until(self, target_time, log_file_path=None):
        """Attendre jusqu'à une heure spécifique"""
        now = datetime.now()
        if target_time > now:
            wait_seconds = (target_time - now).total_seconds()
            self.log_info(f"Attente de {wait_seconds/3600:.1f} heures jusqu'à {target_time.strftime('%H:%M')}", log_file_path)
            time.sleep(wait_seconds)

    def log_info(self, message, log_file_path=None):
        """Logger une information dans le bon fichier de log"""
        timestamp = datetime.now().isoformat()
        log_entry = {"timestamp": timestamp, "level": "info", "message": message}
        if log_file_path:
            self.append_log_to_file(log_file_path, log_entry)
        else:
            self.append_log(log_entry)

    def log_error(self, message, log_file_path=None):
        """Logger une erreur dans le bon fichier de log"""
        timestamp = datetime.now().isoformat()
        log_entry = {"timestamp": timestamp, "level": "error", "message": message}
        if log_file_path:
            self.append_log_to_file(log_file_path, log_entry)
        else:
            self.append_log(log_entry)

    def append_log_to_file(self, log_file_path, log_entry):
        try:
            with open(log_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            data["logs"].append(log_entry)
            with open(log_file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(json.dumps({"error": f"Erreur append_log_to_file: {str(e)}"}))

    def print_final_report(self):
        """Afficher le rapport final"""
        total_sessions = len(self.session_logs)
        completed_sessions = len([s for s in self.session_logs if s["status"] == "completed"])
        total_likes = sum(s.get("total_likes", 0) for s in self.session_logs)

        report = {
            "session_duration": str(datetime.now() - self.start_time),
            "total_sessions": total_sessions,
            "completed_sessions": completed_sessions,
            "failed_sessions": total_sessions - completed_sessions,
            "total_likes_planned": total_likes,
            "log_file": self.log_file_path,
            "sessions": self.session_logs
        }

        # Mettre à jour le fichier de logs avec le rapport final
        try:
            with open(self.log_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            data["session_end"] = datetime.now().isoformat()
            data["final_report"] = report

            with open(self.log_file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)

        except Exception as e:
            print(json.dumps({"error": f"Erreur mise à jour rapport final: {str(e)}"}))

        # Afficher le rapport sur stdout aussi
        print(json.dumps(report, indent=2))

    def update_global_stats(self, log_file_path, session_log):
        """Mettre à jour les statistiques globales dans le fichier de log"""
        try:
            with open(log_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Mettre à jour les statistiques globales
            data["global_stats"]["total_likes"] += session_log["total_likes"]
            data["global_stats"]["total_sessions"] += 1
            data["global_stats"]["last_session"] = session_log["session_end"]

            with open(log_file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(json.dumps({"error": f"Erreur mise à jour statistiques globales: {str(e)}"}))

    def is_campaign_paused(self):
        if not self.campagne_id or not API_TOKEN:
            return False  # Pas de contrôle si pas d'ID ou de token
        try:
            resp = requests.get(
                f"{API_URL}/api/social_campagnes/{self.campagne_id}/status",
                headers={"Authorization": f"Bearer {API_TOKEN}"}, timeout=5
            )
            if resp.status_code == 200:
                return resp.json().get("status") == "paused"
        except Exception as e:
            print(f"[WARN] Impossible de vérifier le statut de la campagne: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print('{"error": "Usage: instagram_engagement_controller.py <config_file.json> [campagne_id]"}')
        print('{"error": "Exemple: instagram_engagement_controller.py config.json 123"}')
        sys.exit(1)

    config_file = sys.argv[1]
    campagne_id = sys.argv[2] if len(sys.argv) > 2 else None

    try:
        with open(config_file, 'r') as f:
            accounts_config = json.load(f)

        controller = InstagramEngagementController(accounts_config, campagne_id)
        controller.run_engagement_sessions()

    except FileNotFoundError:
        print('{"error": f"Fichier de configuration {config_file} non trouvé"}')
        sys.exit(1)
    except json.JSONDecodeError:
        print('{"error": "Format JSON invalide dans le fichier de configuration"}')
        sys.exit(1)
    except Exception as e:
        print(f'{{"error": "Erreur générale: {str(e)}"}}')
        sys.exit(1)

if __name__ == "__main__":
    main()
