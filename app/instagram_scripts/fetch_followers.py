import sys
from base_instagram_client import BaseInstagramClient

def fetch_followers(username, password, target_username, limit=None, offset=0, cursor=None):
    try:
        # Initialiser le client Instagram
        client = BaseInstagramClient(username, password)

        # Validation et récupération de l'ID utilisateur
        target_username = client.validate_username(target_username)
        target_user_id = client.get_user_id_from_username(target_username)

        # Récupérer les followers avec pagination
        try:
            # Validation des paramètres
            if limit:
                limit = int(limit)
                if limit <= 0:
                    raise ValueError("limit doit être positif")

            if offset:
                offset = int(offset)
                if offset < 0:
                    raise ValueError("offset doit être positif ou nul")

            # Utiliser la méthode de bas niveau pour la pagination
            followers_list = []
            end_cursor = cursor if cursor else None
            total_fetched = 0

            # Si on a un offset, on doit d'abord avancer jusqu'à cette position
            while total_fetched < offset:
                chunk_size = min(50, offset - total_fetched)  # Récupérer par chunks de 50
                chunk, end_cursor = client.client.user_followers_gql_chunk(target_user_id, max_amount=chunk_size, end_cursor=end_cursor)
                if not chunk:
                    break
                total_fetched += len(chunk)
                if not end_cursor:
                    break

            # Maintenant récupérer les followers demandés
            remaining_limit = limit if limit else 200
            while len(followers_list) < remaining_limit:
                chunk_size = min(50, remaining_limit - len(followers_list))
                chunk, end_cursor = client.client.user_followers_gql_chunk(target_user_id, max_amount=chunk_size, end_cursor=end_cursor)
                if not chunk:
                    break
                followers_list.extend(chunk)
                if not end_cursor:
                    break

            # Limiter le nombre de followers selon la limite demandée
            if limit:
                followers_list = followers_list[:limit]

            # Formater les données des followers
            followers_data = []
            for follower in followers_list:
                follower_data = client.format_user_info(follower)
                followers_data.append(follower_data)

            # Retourner les résultats
            result = {
                "target_username": target_username,
                "target_user_id": str(target_user_id),
                "followers_count": len(followers_data),
                "offset": offset,
                "limit": limit,
                "cursor": end_cursor,
                "followers": followers_data
            }
            client.print_json_result(result)

        except Exception as e:
            client.print_error(f"Erreur lors de la récupération des followers: {str(e)}")
            return

    except Exception as e:
        client.print_error(str(e))
        return

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print('{"error": "Usage: fetch_followers.py <username> <password> <target_username> [limit] [offset] [cursor]"}')
        print('{"error": "Exemple: fetch_followers.py username password target_user 100"}')
        print('{"error": "Exemple avec offset: fetch_followers.py username password target_user 200 200"}')
        print('{"error": "Exemple avec cursor: fetch_followers.py username password target_user 200 0 23456ERTGFD"}')
        sys.exit(1)

    username = sys.argv[1]
    password = sys.argv[2]
    target_username = sys.argv[3]

    # Paramètres optionnels
    limit = None
    offset = 0
    cursor = None

    if len(sys.argv) > 4:
        limit = sys.argv[4]
    if len(sys.argv) > 5:
        offset = sys.argv[5]
    if len(sys.argv) > 6:
        cursor = sys.argv[6]

    fetch_followers(username, password, target_username, limit, offset, cursor)
