import sys
import asyncio
import os
import json
from datetime import datetime, timedelta
from aiograpi import Client
from aiograpi.exceptions import LoginRequired

async def fetch_messages(username, password, hours_back=0.5, recipient_id=None):
    cl = Client()
    session_path = f"session_{username}.json"
    login_via_session = False
    login_via_pw = False
    messages_data = []
    cutoff_time = datetime.now() - timedelta(hours=hours_back)
    try:
        # Authentification
        if os.path.exists(session_path):
            session = cl.load_settings(session_path)
            try:
                cl.set_settings(session)
                await cl.login(username, password)
                try:
                    await cl.get_timeline_feed()
                except LoginRequired:
                    old_session = cl.get_settings()
                    cl.set_settings({})
                    cl.set_uuids(old_session["uuids"])
                    await cl.login(username, password)
                login_via_session = True
            except Exception as e:
                pass
        if not login_via_session:
            try:
                if await cl.login(username, password):
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
            user_id = recipient_id
        except ValueError:
            print(json.dumps({"error": "fetch_messages.py attend un user_id numérique, pas un handle"}))
            return

        # Récupération des threads et recherche du thread cible
        inbox = await cl.direct_threads()
        target_thread = None
        for thread in inbox:
            if any(u.pk == user_id for u in thread.users):
                target_thread = thread
                break

        # Vérification que le thread a été trouvé
        if not target_thread:
            print(json.dumps([]))
            return

        # Récupération des messages
        messages = await cl.direct_messages(target_thread.id, amount=50)
        for message in messages:
            message_time = message.timestamp
            if message_time >= cutoff_time:
                is_incoming = message.user_id != cl.user_id
                message_data = {
                    "thread_id": str(target_thread.id),
                    "message_id": str(message.id),
                    "sender_id": str(message.user_id),
                    "sender_username": None,  # On ne récupère plus les infos utilisateur côté Python
                    "sender_full_name": None,
                    "text": message.text,
                    "timestamp": str(message.timestamp),
                    "datetime": message_time.isoformat(),
                    "is_incoming": is_incoming
                }
                messages_data.append(message_data)
        print(json.dumps(messages_data, ensure_ascii=False))
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        return

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(json.dumps({"error": "Usage: fetch_messages.py <username> <password> [hours_back] [recipient_id]"}))
        sys.exit(1)

    username = sys.argv[1]
    password = sys.argv[2]
    hours_back = int(sys.argv[3]) if len(sys.argv) > 3 else 24
    recipient_id = sys.argv[4] if len(sys.argv) > 4 else None

    asyncio.run(fetch_messages(username, password, hours_back, recipient_id))
