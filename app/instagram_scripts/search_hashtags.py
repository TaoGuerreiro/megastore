import sys
import random
from base_instagram_client import BaseInstagramClient

def search_hashtags(username, password, hashtag_name, action="info", amount=20, cursor=None):
    """
    Rechercher des informations sur un hashtag avec méthodes low-level

    Args:
        username: Nom d'utilisateur Instagram
        password: Mot de passe Instagram
        hashtag_name: Nom du hashtag (sans #)
        action: Type d'action ("info", "recent", "top", "related")
        amount: Nombre de posts à récupérer (pour recent/top)
        cursor: Curseur pour la pagination (optionnel)
    """
    try:
        # Initialiser le client Instagram
        client = BaseInstagramClient(username, password)

        # Nettoyer le nom du hashtag (enlever le # si présent)
        if hashtag_name.startswith("#"):
            hashtag_name = hashtag_name[1:]

        if not hashtag_name:
            client.print_error("Le nom du hashtag ne peut pas être vide")
            return

        # Validation du amount
        try:
            amount = int(amount)
            if amount <= 0:
                raise ValueError("amount doit être positif")
            if amount > 100:  # Limite pour éviter la surcharge
                amount = 100
        except ValueError:
            client.print_error(f"amount doit être un nombre valide, reçu: {amount}")
            return

        result = {}

        if action == "info":
            # Récupérer les informations du hashtag avec méthode low-level
            try:
                # Essayer d'abord l'API publique A1
                try:
                    hashtag_info = client.client.hashtag_info_a1(hashtag_name)
                except Exception:
                    # Si A1 échoue, essayer l'API privée V1
                    hashtag_info = client.client.hashtag_info_v1(hashtag_name)

                result = {
                    "hashtag_name": hashtag_name,
                    "action": "info",
                    "method": "low_level",
                    "current_cursor": cursor,
                    "hashtag_info": {
                        "id": str(hashtag_info.id),
                        "name": hashtag_info.name,
                        "media_count": getattr(hashtag_info, 'media_count', 0),
                        "profile_pic_url": str(hashtag_info.profile_pic_url) if getattr(hashtag_info, 'profile_pic_url', None) else None
                    }
                }
            except Exception as e:
                client.print_error(f"Erreur lors de la récupération des infos du hashtag: {str(e)}")
                return

        elif action == "recent":
            # Récupérer les posts récents avec méthode low-level et pagination
            try:
                # Utiliser la méthode low-level avec gestion du curseur
                medias, next_cursor = client.client.hashtag_medias_v1_chunk(
                    hashtag_name,
                    max_amount=amount,
                    tab_key='recent',
                    max_id=cursor
                )

                result = {
                    "hashtag_name": hashtag_name,
                    "action": "recent",
                    "method": "low_level_v1_chunk",
                    "amount_requested": amount,
                    "amount_retrieved": len(medias),
                    "current_cursor": cursor,
                    "next_cursor": next_cursor,
                    "has_more": bool(next_cursor),
                    "posts": [client.format_media_info(media) for media in medias]
                }
            except Exception as e:
                client.print_error(f"Erreur lors de la récupération des posts récents: {str(e)}")
                return

        elif action == "top":
            # Récupérer les posts populaires avec méthode low-level et pagination
            try:
                # Utiliser la méthode low-level avec gestion du curseur
                medias, next_cursor = client.client.hashtag_medias_v1_chunk(
                    hashtag_name,
                    max_amount=amount,
                    tab_key='top',
                    max_id=cursor
                )

                result = {
                    "hashtag_name": hashtag_name,
                    "action": "top",
                    "method": "low_level_v1_chunk",
                    "amount_requested": amount,
                    "amount_retrieved": len(medias),
                    "current_cursor": cursor,
                    "next_cursor": next_cursor,
                    "has_more": bool(next_cursor),
                    "posts": [client.format_media_info(media) for media in medias]
                }
            except Exception as e:
                client.print_error(f"Erreur lors de la récupération des posts populaires: {str(e)}")
                return

        elif action == "recent_a1":
            # Récupérer les posts récents avec API publique A1 et pagination
            try:
                # Utiliser la méthode low-level A1 avec gestion du curseur
                medias, next_cursor = client.client.hashtag_medias_a1_chunk(
                    hashtag_name,
                    max_amount=amount,
                    tab_key='edge_hashtag_to_media',
                    end_cursor=cursor
                )

                result = {
                    "hashtag_name": hashtag_name,
                    "action": "recent_a1",
                    "method": "low_level_a1_chunk",
                    "amount_requested": amount,
                    "amount_retrieved": len(medias),
                    "current_cursor": cursor,
                    "next_cursor": next_cursor,
                    "has_more": bool(next_cursor),
                    "posts": [client.format_media_info(media) for media in medias]
                }
            except Exception as e:
                client.print_error(f"Erreur lors de la récupération des posts récents (A1): {str(e)}")
                return

        elif action == "top_a1":
            # Récupérer les posts populaires avec API publique A1 et pagination
            try:
                # Utiliser la méthode low-level A1 avec gestion du curseur
                medias, next_cursor = client.client.hashtag_medias_a1_chunk(
                    hashtag_name,
                    max_amount=amount,
                    tab_key='edge_hashtag_to_top_posts',
                    end_cursor=cursor
                )

                result = {
                    "hashtag_name": hashtag_name,
                    "action": "top_a1",
                    "method": "low_level_a1_chunk",
                    "amount_requested": amount,
                    "amount_retrieved": len(medias),
                    "current_cursor": cursor,
                    "next_cursor": next_cursor,
                    "has_more": bool(next_cursor),
                    "posts": [client.format_media_info(media) for media in medias]
                }
            except Exception as e:
                client.print_error(f"Erreur lors de la récupération des posts populaires (A1): {str(e)}")
                return

        elif action == "related":
            # Récupérer les hashtags liés (pas de pagination pour cette action)
            try:
                related_hashtags = client.client.hashtag_related_hashtags(hashtag_name)
                result = {
                    "hashtag_name": hashtag_name,
                    "action": "related",
                    "method": "low_level",
                    "current_cursor": cursor,
                    "related_hashtags_count": len(related_hashtags),
                    "related_hashtags": []
                }

                for hashtag in related_hashtags:
                    hashtag_data = {
                        "id": str(hashtag.id),
                        "name": hashtag.name,
                        "media_count": getattr(hashtag, 'media_count', 0),
                        "profile_pic_url": str(hashtag.profile_pic_url) if getattr(hashtag, 'profile_pic_url', None) else None
                    }
                    result["related_hashtags"].append(hashtag_data)

            except Exception as e:
                client.print_error(f"Erreur lors de la récupération des hashtags liés: {str(e)}")
                return

        else:
            client.print_error(f"Action non reconnue: {action}. Actions disponibles: info, recent, top, recent_a1, top_a1, related")
            return

        # Ajouter l'horodatage
        result["timestamp"] = client.get_current_timestamp()

        # Afficher le résultat
        client.print_json_result(result)

    except Exception as e:
        client.print_error(str(e))
        return

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print('{"error": "Usage: search_hashtags.py <username> <password> <hashtag_name> [action] [amount] [cursor]"}')
        print('{"error": "Actions disponibles: info, recent, top, recent_a1, top_a1, related"}')
        print('{"error": "Exemple: search_hashtags.py username password fashion recent 20"}')
        print('{"error": "Exemple avec pagination: search_hashtags.py username password fashion recent 20 QVFDR0dzT3FJT0V4amFjMaQ3czlGVzRKV3FNWDJqaE1mWmltWU5VWGYtbnV6RVpoOUlsR3dCN05RRmpLc2R5SVlCQTNaekV5bUVOV0F4Vno1MDkxN1Nndg=="}')
        sys.exit(1)

    username = sys.argv[1]
    password = sys.argv[2]
    hashtag_name = sys.argv[3]

    # Paramètres optionnels
    action = "info"  # Par défaut
    amount = 20
    cursor = None

    if len(sys.argv) > 4:
        action = sys.argv[4]
    if len(sys.argv) > 5:
        amount = sys.argv[5]
    if len(sys.argv) > 6:
        cursor = sys.argv[6] if sys.argv[6] != "null" else None

    search_hashtags(username, password, hashtag_name, action, amount, cursor)
