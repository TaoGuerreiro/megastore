import sys
import os
import json
from datetime import datetime, timedelta
from instagrapi import Client
from instagrapi.exceptions import LoginRequired

def fetch_messages(username, password, hours_back=0.5, recipient_id=None):
    cl = Client()
    session_path = f"session_{username}.json"
    login_via_session = False
    login_via_pw = False
    messages_data = []

    # Validation du hours_back
    try:
        hours_back = float(hours_back)
        if hours_back < 0 or hours_back > 8760:  # Max 1 an
            raise ValueError("hours_back doit être entre 0 et 8760")
    except (ValueError, TypeError):
        print(json.dumps({"error": f"hours_back invalide: {hours_back}. Doit être un nombre entre 0 et 8760"}))
        return

    cutoff_time = datetime.now() - timedelta(hours=hours_back)

    try:
        # Authentification
        if os.path.exists(session_path):
            try:
                cl.load_settings(session_path)
                cl.login(username, password)
                try:
                    cl.get_timeline_feed()
                except LoginRequired:
                    cl.login(username, password)
                login_via_session = True
            except Exception as e:
                pass
        if not login_via_session:
            try:
                if cl.login(username, password):
                    login_via_pw = True
            except Exception as e:
                pass
        if not login_via_pw and not login_via_session:
            raise Exception("Impossible de se connecter à Instagram avec la session ou le mot de passe")
        cl.dump_settings(session_path)

        # Validation du recipient_id

        if not recipient_id:
            print(json.dumps({"error": "user_id manquant"}))
            return
        try:
            user_id = int(recipient_id)
            if user_id <= 0:
                raise ValueError("user_id doit être positif")
        except ValueError:
            print(json.dumps({"error": f"fetch_messages.py attend un user_id numérique valide, reçu: {recipient_id}"}))
            return

        # Récupération des threads et recherche du thread cible
        inbox = cl.direct_threads()
        target_thread = None
        # Debug : Afficher tous les user_id présents dans les threads
        for thread in inbox:
            user_pks = [u.pk for u in thread.users]
            print(json.dumps({"thread_id": thread.id, "user_pks": user_pks}), file=sys.stderr)
            if any(str(u.pk) == str(user_id) for u in thread.users):
                target_thread = thread
                break

        # Vérification que le thread a été trouvé
        if not target_thread:
            print(json.dumps({"error": "Aucun thread trouvé pour ce user_id"}))
            return

        # Récupération des messages
        messages = cl.direct_messages(target_thread.id, amount=50)
        for message in messages:
            message_time = message.timestamp
            if message_time >= cutoff_time:
                message_data = {
                    "thread_id": str(target_thread.id),
                    "message_id": str(message.id),
                    "sender_id": str(message.user_id),
                    "sender_username": None,  # On ne récupère plus les infos utilisateur côté Python
                    "sender_full_name": None,
                    "text": message.text,
                    "timestamp": str(message.timestamp),
                    "datetime": message_time.isoformat()
                }
                messages_data.append(message_data)
        print(json.dumps(messages_data, ensure_ascii=False))
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        return

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(json.dumps({"error": "Usage: fetch_messages.py <username> <password> [hours_back] [recipient_id]"}))
        print(json.dumps({"error": "Exemple: fetch_messages.py username password 24 123456789"}))
        sys.exit(1)

    username = sys.argv[1]
    password = sys.argv[2]

    # Gestion intelligente des paramètres
    if len(sys.argv) == 3:
        # Seulement username et password fournis
        hours_back = 24
        recipient_id = None
    elif len(sys.argv) == 4:
        # username, password et un paramètre supplémentaire
        param3 = sys.argv[3]
        try:
            # Si c'est un nombre, c'est probablement hours_back
            hours_back = float(param3)
            recipient_id = None
        except ValueError:
            # Si ce n'est pas un nombre, c'est probablement recipient_id
            hours_back = 24
            recipient_id = param3
    else:
        # username, password, hours_back, recipient_id
        hours_back = sys.argv[3]
        recipient_id = sys.argv[4]

    fetch_messages(username, password, hours_back, recipient_id)
