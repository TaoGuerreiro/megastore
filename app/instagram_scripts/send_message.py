import sys
import os
from instagrapi import Client
from instagrapi.exceptions import LoginRequired
import json
from datetime import datetime

def send_message(username, password, recipient, message):
    cl = Client()
    session_path = f"session_{username}.json"
    login_via_session = False
    login_via_pw = False

    try:
        # Tente de charger la session si elle existe
        if os.path.exists(session_path):
            try:
                cl.load_settings(session_path)
                cl.login(username, password)
                # Vérifie la validité de la session
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

        # Sauvegarde la session à chaque fois
        cl.dump_settings(session_path)

        # Validation du recipient_id
        try:
            user_id = int(recipient)
        except ValueError:
            print(json.dumps({"error": "send_message.py attend un user_id numérique, pas un handle"}))
            return

        # Envoi du message
        result = cl.direct_send(message, [user_id])

        # Récupération des informations du message envoyé
        # Choix du timestamp à retourner
        if hasattr(result, 'taken_at') and result.taken_at:
            instagram_timestamp = result.taken_at.isoformat()
        elif hasattr(result, 'timestamp') and result.timestamp:
            if isinstance(result.timestamp, datetime):
                instagram_timestamp = result.timestamp.isoformat()
            else:
                instagram_timestamp = str(result.timestamp)
        else:
            instagram_timestamp = None

        message_info = {
            "success": True,
            "message": "Message envoyé avec succès",
            "instagram_message_id": str(result.id) if hasattr(result, 'id') else None,
            "instagram_sender_id": str(cl.user_id) if hasattr(cl, 'user_id') else None,
            "instagram_sender_username": username,
            "instagram_timestamp": instagram_timestamp
        }

        print(json.dumps(message_info))

    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print(json.dumps({"error": "Usage: send_message.py <username> <password> <recipient_id> <message>"}))
        sys.exit(1)
    username, password, recipient, message = sys.argv[1:5]
    send_message(username, password, recipient, message)
