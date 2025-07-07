import sys
import random
import json
from base_instagram_client import BaseInstagramClient

def like_random_posts(username, password, target, count=2):
    """
    Liker des posts aléatoirement

    Args:
        username: Nom d'utilisateur Instagram
        password: Mot de passe Instagram
        target: target_user_id (string) ou liste de media_ids (array)
        count: Nombre de posts à liker
    """
    try:
        # Initialiser le client Instagram
        client = BaseInstagramClient(username, password)

        # Validation du count
        try:
            count = int(count)
            if count <= 0:
                raise ValueError("count doit être positif")
            if count > 20:  # Limite pour éviter le spam
                count = 20
        except ValueError:
            client.print_error(f"count doit être un nombre valide, reçu: {count}")
            return

        available_posts = []

        # Détecter automatiquement le mode selon le type de target
        if isinstance(target, str) and target.isdigit():
            # Mode utilisateur : target est un user_id
            mode = "user"
            target_user_id = client.validate_user_id(target)

            # Récupérer les publications de l'utilisateur
            try:
                medias = client.get_user_medias(target_user_id, amount=20)

                if not medias:
                    client.print_error("Aucune publication trouvée pour cet utilisateur")
                    return

                # Filtrer les publications qui ne sont pas déjà likées
                for media in medias:
                    try:
                        # Vérifier si le post n'est pas déjà liké
                        if not media.has_liked:
                            available_posts.append(media)
                    except Exception as e:
                        # Si on ne peut pas vérifier, on inclut quand même
                        available_posts.append(media)

            except Exception as e:
                client.print_error(f"Erreur lors de la récupération des publications: {str(e)}")
                return

        elif isinstance(target, list) or (isinstance(target, str) and target.startswith('[')):
            # Mode posts : target est une liste de media_ids
            mode = "posts"

            # Parser la liste de media_ids
            try:
                if isinstance(target, str):
                    # Si c'est une chaîne JSON
                    media_ids = json.loads(target)
                else:
                    # Si c'est déjà une liste
                    media_ids = target

                if not isinstance(media_ids, list):
                    client.print_error("target doit être une liste de media_ids")
                    return

                # Récupérer les informations de chaque post
                for media_id in media_ids:
                    try:
                        # Récupérer les détails du post
                        media = client.client.media_info(media_id)

                        # Vérifier si le post n'est pas déjà liké
                        if not media.has_liked:
                            available_posts.append(media)
                    except Exception as e:
                        client.print_error(f"Erreur lors de la récupération du post {media_id}: {str(e)}")
                        continue

            except json.JSONDecodeError:
                client.print_error("Format JSON invalide pour la liste de media_ids")
                return
            except Exception as e:
                client.print_error(f"Erreur lors du parsing de la liste de posts: {str(e)}")
                return

        else:
            client.print_error(f"Format de target invalide. Doit être un user_id (string numérique) ou une liste de media_ids (array/JSON)")
            return

        if not available_posts:
            client.print_error("Aucune publication disponible à liker (toutes déjà likées ou privées)")
            return

        # Sélectionner aléatoirement les posts à liker
        posts_to_like = random.sample(available_posts, min(count, len(available_posts)))

        # Liker les posts sélectionnés
        liked_posts = []
        for media in posts_to_like:
            try:
                # Liker le post
                client.client.media_like(media.id)

                # Récupérer les informations du post liké
                post_info = client.format_media_info(media)
                post_info["liked_at"] = client.get_current_timestamp()
                liked_posts.append(post_info)

            except Exception as e:
                client.print_error(f"Erreur lors du like du post {media.id}: {str(e)}")
                continue

        # Retourner les résultats
        result = {
            "mode": mode,
            "target": str(target) if mode == "user" else target,
            "requested_likes": count,
            "successful_likes": len(liked_posts),
            "available_posts": len(available_posts),
            "total_posts_processed": len(available_posts),
            "liked_posts": liked_posts
        }
        client.print_json_result(result)

    except Exception as e:
        client.print_error(str(e))
        return

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print('{"error": "Usage: like_random_posts.py <username> <password> <target> [count]"}')
        print('{"error": "Mode user: like_random_posts.py username password 123456789 2"}')
        print('{"error": "Mode posts: like_random_posts.py username password \'[\"media_id1\",\"media_id2\"]\' 2"}')
        sys.exit(1)

    username = sys.argv[1]
    password = sys.argv[2]
    target = sys.argv[3]

    # Paramètre optionnel pour le nombre de likes
    count = 2  # Par défaut, liker 2 posts
    if len(sys.argv) > 4:
        count = sys.argv[4]

    # Détecter automatiquement le type de target
    if target.startswith('['):
        # C'est un JSON array
        try:
            target = json.loads(target)
        except json.JSONDecodeError:
            pass

    like_random_posts(username, password, target, count)
