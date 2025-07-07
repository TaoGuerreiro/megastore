import sys
from base_instagram_client import BaseInstagramClient

def send_message(username, password, recipient, message):
    try:
        # Initialiser le client Instagram
        client = BaseInstagramClient(username, password)

        # Validation du recipient_id
        try:
            user_id = int(recipient)
        except ValueError:
            client.print_error("send_message.py attend un user_id numérique, pas un handle")
            return

        # Envoi du message
        result = client.client.direct_send(message, [user_id])

        # Récupération des informations du message envoyé
        # Choix du timestamp à retourner
        if hasattr(result, 'taken_at') and result.taken_at:
            instagram_timestamp = result.taken_at.isoformat()
        elif hasattr(result, 'timestamp') and result.timestamp:
            if hasattr(result.timestamp, 'isoformat'):
                instagram_timestamp = result.timestamp.isoformat()
            else:
                instagram_timestamp = str(result.timestamp)
        else:
            instagram_timestamp = None

        message_info = {
            "success": True,
            "message": "Message envoyé avec succès",
            "instagram_message_id": str(result.id) if hasattr(result, 'id') else None,
            "instagram_sender_id": str(client.client.user_id) if hasattr(client.client, 'user_id') else None,
            "instagram_sender_username": username,
            "instagram_timestamp": instagram_timestamp
        }

        client.print_json_result(message_info)

    except Exception as e:
        client.print_error(str(e))

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print('{"error": "Usage: send_message.py <username> <password> <recipient_id> <message>"}')
        sys.exit(1)
    username, password, recipient, message = sys.argv[1:5]
    send_message(username, password, recipient, message)
