import sys
from base_instagram_client import BaseInstagramClient

def fetch_user_id(username, password, handle):
    try:
        # Initialiser le client Instagram
        client = BaseInstagramClient(username, password)

        # Récupérer l'ID utilisateur
        user_id = client.get_user_id_from_username(handle)

        # Retourner le résultat
        client.print_json_result({"user_id": str(user_id)})

    except Exception as e:
        client.print_error(str(e))

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print('{"error": "Usage: fetch_user_id.py <username> <password> <handle>"}')
        sys.exit(1)
    username = sys.argv[1]
    password = sys.argv[2]
    handle = sys.argv[3]
    fetch_user_id(username, password, handle)
