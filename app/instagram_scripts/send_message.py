import sys
import asyncio
import os
from aiograpi import Client
from aiograpi.exceptions import LoginRequired

async def send_message(username, password, recipient, message):
    cl = Client()
    session_path = f"session_{username}.json"
    login_via_session = False
    login_via_pw = False

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
            print(f"Erreur lors du login avec la session : {e}")

    if not login_via_session:
        try:
            if await cl.login(username, password):
                login_via_pw = True
        except Exception as e:
            print(f"Erreur lors du login avec mot de passe : {e}")

    if not login_via_pw and not login_via_session:
        raise Exception("Impossible de se connecter à Instagram avec la session ou le mot de passe")

    # Sauvegarde la session à chaque fois
    cl.dump_settings(session_path)
    user_id = await cl.user_id_from_username(recipient)
    await cl.direct_send(message, [user_id])

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage: send_message.py <username> <password> <recipient> <message>")
        sys.exit(1)
    username, password, recipient, message = sys.argv[1:5]
    asyncio.run(send_message(username, password, recipient, message))
