import sys
from datetime import datetime, timedelta
from base_instagram_client import BaseInstagramClient

def fetch_messages(username, password, hours_back=0.5, recipient_id=None):
    try:
        # Initialiser le client Instagram
        client = BaseInstagramClient(username, password)

        # Validation du hours_back
        try:
            hours_back = float(hours_back)
            if hours_back < 0 or hours_back > 8760:  # Max 1 an
                raise ValueError("hours_back doit être entre 0 et 8760")
        except (ValueError, TypeError):
            client.print_error(f"hours_back invalide: {hours_back}. Doit être un nombre entre 0 et 8760")
            return

        cutoff_time = datetime.now() - timedelta(hours=hours_back)

        # Validation du recipient_id
        if not recipient_id:
            client.print_error("user_id manquant")
            return

        user_id = client.validate_user_id(recipient_id)

        # Récupération des threads et recherche du thread cible
        inbox = client.client.direct_threads()
        target_thread = None
        messages_data = []

        # Debug : Afficher tous les user_id présents dans les threads
        for thread in inbox:
            user_pks = [u.pk for u in thread.users]
            print('{"thread_id": "' + str(thread.id) + '", "user_pks": ' + str(user_pks) + '}', file=sys.stderr)
            if any(str(u.pk) == str(user_id) for u in thread.users):
                target_thread = thread
                break

        # Vérification que le thread a été trouvé
        if not target_thread:
            client.print_error("Aucun thread trouvé pour ce user_id")
            return

        # Récupération des messages
        messages = client.client.direct_messages(target_thread.id, amount=50)
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

        client.print_json_result(messages_data)

    except Exception as e:
        client.print_error(str(e))
        return

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print('{"error": "Usage: fetch_messages.py <username> <password> [hours_back] [recipient_id]"}')
        print('{"error": "Exemple: fetch_messages.py username password 24 123456789"}')
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
