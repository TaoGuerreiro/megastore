import sys
import asyncio
import os
from aiograpi import Client
from aiograpi.exceptions import LoginRequired
import json

async def send_message(username, password, recipient, message):
    cl = Client()
    session_path = f"session_{username}.json"
    login_via_session = False
    login_via_pw = False

    try:
        # Tente de charger la session si elle existe
        if os.path.exists(session_path):
            session = cl.load_settings(session_path)
            try:
                cl.set_settings(session)
                await cl.login(username, password)
                # Vérifie la validité de la session
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

        # Sauvegarde la session à chaque fois
        cl.dump_settings(session_path)

        # Validation du recipient_id
        try:
            user_id = int(recipient)
        except ValueError:
            print(json.dumps({"error": "send_message.py attend un user_id numérique, pas un handle"}))
            return

        # Envoi du message
        await cl.direct_send(message, [user_id])
        print(json.dumps({"success": True, "message": "Message envoyé avec succès"}))

    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print(json.dumps({"error": "Usage: send_message.py <username> <password> <recipient_id> <message>"}))
        sys.exit(1)
    username, password, recipient, message = sys.argv[1:5]
    asyncio.run(send_message(username, password, recipient, message))
