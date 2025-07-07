# frozen_string_literal: true
"""
Service pour la gestion des utilisateurs Instagram
"""

import json
from typing import List, Dict, Any, Optional, Union
from ..core.client import InstagramClient, UserInfo, MediaInfo
from ..core.logger import InstagramLogger


class UserService:
    """Service pour la gestion des utilisateurs Instagram"""

    def __init__(self, client: InstagramClient, logger: InstagramLogger):
        """
        Initialiser le service utilisateur

        Args:
            client: Client Instagram authentifié
            logger: Logger pour tracer les actions
        """
        self.client = client
        self.logger = logger

    def get_user_info(self, username: str) -> UserInfo:
        """
        Récupérer les informations d'un utilisateur

        Args:
            username: Nom d'utilisateur Instagram

        Returns:
            Informations de l'utilisateur
        """
        try:
            username = self.client.validate_username(username)
            user_id = self.client.get_user_id_from_username(username)

            # Récupérer les informations complètes
            user_info = self.client.client.user_info(user_id)
            formatted_info = self.client.format_user_info(user_info)

            self.logger.log_action("user_info", {
                "username": username,
                "user_id": str(user_id),
                "follower_count": formatted_info.follower_count,
                "is_private": formatted_info.is_private
            })

            return formatted_info

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des infos de l'utilisateur {username}: {str(e)}")
            raise

    def get_user_posts(self, username: str, amount: int = 20) -> List[MediaInfo]:
        """
        Récupérer les posts d'un utilisateur

        Args:
            username: Nom d'utilisateur Instagram
            amount: Nombre de posts à récupérer

        Returns:
            Liste des posts de l'utilisateur
        """
        try:
            username = self.client.validate_username(username)
            user_id = self.client.get_user_id_from_username(username)

            medias = self.client.get_user_medias(user_id, amount)
            posts = [self.client.format_media_info(media) for media in medias]

            self.logger.log_action("user_posts", {
                "username": username,
                "user_id": str(user_id),
                "posts_count": len(posts),
                "amount_requested": amount
            })

            return posts

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des posts de l'utilisateur {username}: {str(e)}")
            raise

    def get_user_followers(self, username: str, limit: Optional[int] = None,
                          offset: int = 0, cursor: Optional[str] = None) -> Dict[str, Any]:
        """
        Récupérer les followers d'un utilisateur

        Args:
            username: Nom d'utilisateur Instagram
            limit: Nombre de followers à récupérer
            offset: Offset pour la pagination
            cursor: Curseur pour la pagination

        Returns:
            Followers avec pagination
        """
        try:
            username = self.client.validate_username(username)
            user_id = self.client.get_user_id_from_username(username)

            # Validation des paramètres
            if limit and limit <= 0:
                raise ValueError("limit doit être positif")
            if offset < 0:
                raise ValueError("offset doit être positif ou nul")

            followers_list = []
            end_cursor = cursor
            total_fetched = 0

            # Gérer l'offset
            while total_fetched < offset:
                chunk_size = min(50, offset - total_fetched)
                chunk, end_cursor = self.client.client.user_followers_gql_chunk(
                    user_id, max_amount=chunk_size, end_cursor=end_cursor
                )
                if not chunk:
                    break
                total_fetched += len(chunk)
                if not end_cursor:
                    break

            # Récupérer les followers demandés
            remaining_limit = limit if limit else 200
            while len(followers_list) < remaining_limit:
                chunk_size = min(50, remaining_limit - len(followers_list))
                chunk, end_cursor = self.client.client.user_followers_gql_chunk(
                    user_id, max_amount=chunk_size, end_cursor=end_cursor
                )
                if not chunk:
                    break
                followers_list.extend(chunk)
                if not end_cursor:
                    break

            # Limiter selon la limite demandée
            if limit:
                followers_list = followers_list[:limit]

            # Formater les données
            followers_data = [self.client.format_user_info(follower) for follower in followers_list]

            result = {
                "target_username": username,
                "target_user_id": str(user_id),
                "followers_count": len(followers_data),
                "offset": offset,
                "limit": limit,
                "cursor": end_cursor,
                "followers": followers_data
            }

            self.logger.log_action("user_followers", {
                "target_username": username,
                "followers_count": len(followers_data),
                "offset": offset,
                "limit": limit
            })

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des followers de {username}: {str(e)}")
            raise

    def get_user_following(self, username: str, limit: Optional[int] = None,
                          offset: int = 0, cursor: Optional[str] = None) -> Dict[str, Any]:
        """
        Récupérer les utilisateurs suivis par un utilisateur

        Args:
            username: Nom d'utilisateur Instagram
            limit: Nombre d'utilisateurs à récupérer
            offset: Offset pour la pagination
            cursor: Curseur pour la pagination

        Returns:
            Utilisateurs suivis avec pagination
        """
        try:
            username = self.client.validate_username(username)
            user_id = self.client.get_user_id_from_username(username)

            # Validation des paramètres
            if limit and limit <= 0:
                raise ValueError("limit doit être positif")
            if offset < 0:
                raise ValueError("offset doit être positif ou nul")

            following_list = []
            end_cursor = cursor
            total_fetched = 0

            # Gérer l'offset
            while total_fetched < offset:
                chunk_size = min(50, offset - total_fetched)
                chunk, end_cursor = self.client.client.user_following_gql_chunk(
                    user_id, max_amount=chunk_size, end_cursor=end_cursor
                )
                if not chunk:
                    break
                total_fetched += len(chunk)
                if not end_cursor:
                    break

            # Récupérer les utilisateurs suivis
            remaining_limit = limit if limit else 200
            while len(following_list) < remaining_limit:
                chunk_size = min(50, remaining_limit - len(following_list))
                chunk, end_cursor = self.client.client.user_following_gql_chunk(
                    user_id, max_amount=chunk_size, end_cursor=end_cursor
                )
                if not chunk:
                    break
                following_list.extend(chunk)
                if not end_cursor:
                    break

            # Limiter selon la limite demandée
            if limit:
                following_list = following_list[:limit]

            # Formater les données
            following_data = [self.client.format_user_info(user) for user in following_list]

            result = {
                "target_username": username,
                "target_user_id": str(user_id),
                "following_count": len(following_data),
                "offset": offset,
                "limit": limit,
                "cursor": end_cursor,
                "following": following_data
            }

            self.logger.log_action("user_following", {
                "target_username": username,
                "following_count": len(following_data),
                "offset": offset,
                "limit": limit
            })

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des utilisateurs suivis par {username}: {str(e)}")
            raise

    def like_user_posts(self, username: str, count: int = 5) -> Dict[str, Any]:
        """
        Liker des posts d'un utilisateur

        Args:
            username: Nom d'utilisateur Instagram
            count: Nombre de posts à liker

        Returns:
            Résultat des likes
        """
        try:
            # Récupérer les posts
            posts = self.get_user_posts(username, count * 2)

            # Filtrer les posts non likés
            available_posts = [post for post in posts if not post.has_liked]

            if not available_posts:
                self.logger.log_info(f"Aucun post disponible à liker pour l'utilisateur {username}")
                return {
                    "username": username,
                    "likes_requested": count,
                    "likes_successful": 0,
                    "available_posts": 0,
                    "message": "Aucun post disponible à liker"
                }

            # Liker les posts
            liked_posts = []
            posts_to_like = available_posts[:count]

            for post in posts_to_like:
                try:
                    self.client.client.media_like(post.media_id)
                    liked_posts.append({
                        "media_id": post.media_id,
                        "liked_at": self.client.get_current_timestamp()
                    })

                    self.logger.log_action("user_post_like", {
                        "username": username,
                        "media_id": post.media_id
                    })

                except Exception as e:
                    self.logger.log_error(f"Erreur lors du like du post {post.media_id}: {str(e)}")

            result = {
                "username": username,
                "likes_requested": count,
                "likes_successful": len(liked_posts),
                "available_posts": len(available_posts),
                "liked_posts": liked_posts
            }

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors du like des posts de l'utilisateur {username}: {str(e)}")
            raise

    def like_random_posts(self, target: Union[str, List[str]], count: int = 2) -> Dict[str, Any]:
        """
        Liker des posts aléatoirement

        Args:
            target: user_id (string) ou liste de media_ids
            count: Nombre de posts à liker

        Returns:
            Résultat des likes
        """
        try:
            available_posts = []

            # Détecter le mode selon le type de target
            if isinstance(target, str) and target.isdigit():
                # Mode utilisateur
                mode = "user"
                target_user_id = self.client.validate_user_id(target)

                # Récupérer les publications
                medias = self.client.get_user_medias(target_user_id, 20)

                if not medias:
                    raise Exception("Aucune publication trouvée pour cet utilisateur")

                # Filtrer les publications non likées
                for media in medias:
                    try:
                        if not media.has_liked:
                            available_posts.append(media)
                    except Exception:
                        available_posts.append(media)

            elif isinstance(target, list) or (isinstance(target, str) and target.startswith('[')):
                # Mode posts
                mode = "posts"

                # Parser la liste de media_ids
                if isinstance(target, str):
                    media_ids = json.loads(target)
                else:
                    media_ids = target

                if not isinstance(media_ids, list):
                    raise ValueError("target doit être une liste de media_ids")

                # Récupérer les informations de chaque post
                for media_id in media_ids:
                    try:
                        media = self.client.client.media_info(media_id)
                        if not media.has_liked:
                            available_posts.append(media)
                    except Exception as e:
                        self.logger.log_error(f"Erreur lors de la récupération du post {media_id}: {str(e)}")
                        continue

            else:
                raise ValueError("Format de target invalide")

            if not available_posts:
                raise Exception("Aucune publication disponible à liker")

            # Sélectionner aléatoirement les posts
            import random
            posts_to_like = random.sample(available_posts, min(count, len(available_posts)))

            # Liker les posts
            liked_posts = []
            for media in posts_to_like:
                try:
                    self.client.client.media_like(media.id)
                    post_info = self.client.format_media_info(media)
                    liked_posts.append({
                        "media_id": post_info.media_id,
                        "owner_username": post_info.owner_username,
                        "liked_at": self.client.get_current_timestamp()
                    })

                    self.logger.log_action("random_post_like", {
                        "mode": mode,
                        "media_id": post_info.media_id,
                        "owner_username": post_info.owner_username
                    })

                except Exception as e:
                    self.logger.log_error(f"Erreur lors du like du post {media.id}: {str(e)}")

            result = {
                "mode": mode,
                "target": str(target) if mode == "user" else target,
                "likes_requested": count,
                "likes_successful": len(liked_posts),
                "available_posts": len(available_posts),
                "liked_posts": liked_posts
            }

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors du like aléatoire: {str(e)}")
            raise
