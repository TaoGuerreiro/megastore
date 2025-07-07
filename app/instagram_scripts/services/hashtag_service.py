# frozen_string_literal: true
"""
Service pour la gestion des hashtags Instagram
"""

import json
from typing import List, Dict, Any, Optional, Tuple
from ..core.client import InstagramClient, MediaInfo
from ..core.logger import InstagramLogger


class HashtagService:
    """Service pour la gestion des hashtags Instagram"""

    def __init__(self, client: InstagramClient, logger: InstagramLogger):
        """
        Initialiser le service hashtag

        Args:
            client: Client Instagram authentifié
            logger: Logger pour tracer les actions
        """
        self.client = client
        self.logger = logger

    def get_hashtag_info(self, hashtag_name: str) -> Dict[str, Any]:
        """
        Récupérer les informations d'un hashtag

        Args:
            hashtag_name: Nom du hashtag (sans #)

        Returns:
            Informations du hashtag
        """
        try:
            # Nettoyer le nom du hashtag
            hashtag_name = self._clean_hashtag_name(hashtag_name)

            # Récupérer les informations
            try:
                hashtag_info = self.client.client.hashtag_info_a1(hashtag_name)
            except Exception:
                hashtag_info = self.client.client.hashtag_info_v1(hashtag_name)

            result = {
                "hashtag_name": hashtag_name,
                "hashtag_id": str(hashtag_info.id),
                "media_count": getattr(hashtag_info, 'media_count', 0),
                "profile_pic_url": str(hashtag_info.profile_pic_url) if getattr(hashtag_info, 'profile_pic_url', None) else None
            }

            self.logger.log_action("hashtag_info", {
                "hashtag": hashtag_name,
                "media_count": result["media_count"]
            })

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des infos du hashtag {hashtag_name}: {str(e)}")
            raise

    def get_hashtag_posts(self, hashtag_name: str, action: str = "recent",
                         amount: int = 20, cursor: Optional[str] = None) -> Dict[str, Any]:
        """
        Récupérer les posts d'un hashtag

        Args:
            hashtag_name: Nom du hashtag (sans #)
            action: Type d'action ("recent", "top", "recent_a1", "top_a1")
            amount: Nombre de posts à récupérer
            cursor: Curseur pour la pagination

        Returns:
            Posts du hashtag avec pagination
        """
        try:
            hashtag_name = self._clean_hashtag_name(hashtag_name)

            if action in ["recent", "top"]:
                # API privée V1
                medias, next_cursor = self.client.client.hashtag_medias_v1_chunk(
                    hashtag_name,
                    max_amount=amount,
                    tab_key=action,
                    max_id=cursor
                )
                method = "low_level_v1_chunk"

            elif action in ["recent_a1", "top_a1"]:
                # API publique A1
                tab_key = "edge_hashtag_to_media" if action == "recent_a1" else "edge_hashtag_to_top_posts"
                medias, next_cursor = self.client.client.hashtag_medias_a1_chunk(
                    hashtag_name,
                    max_amount=amount,
                    tab_key=tab_key,
                    end_cursor=cursor
                )
                method = "low_level_a1_chunk"

            else:
                raise ValueError(f"Action non reconnue: {action}")

            # Formater les posts
            posts = [self.client.format_media_info(media) for media in medias]

            result = {
                "hashtag_name": hashtag_name,
                "action": action,
                "method": method,
                "amount_requested": amount,
                "amount_retrieved": len(posts),
                "current_cursor": cursor,
                "next_cursor": next_cursor,
                "has_more": bool(next_cursor),
                "posts": posts
            }

            self.logger.log_action("hashtag_posts", {
                "hashtag": hashtag_name,
                "action": action,
                "posts_count": len(posts),
                "has_more": result["has_more"]
            })

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des posts du hashtag {hashtag_name}: {str(e)}")
            raise

    def get_related_hashtags(self, hashtag_name: str) -> Dict[str, Any]:
        """
        Récupérer les hashtags liés

        Args:
            hashtag_name: Nom du hashtag (sans #)

        Returns:
            Hashtags liés
        """
        try:
            hashtag_name = self._clean_hashtag_name(hashtag_name)

            related_hashtags = self.client.client.hashtag_related_hashtags(hashtag_name)

            hashtags_data = []
            for hashtag in related_hashtags:
                hashtag_data = {
                    "id": str(hashtag.id),
                    "name": hashtag.name,
                    "media_count": getattr(hashtag, 'media_count', 0),
                    "profile_pic_url": str(hashtag.profile_pic_url) if getattr(hashtag, 'profile_pic_url', None) else None
                }
                hashtags_data.append(hashtag_data)

            result = {
                "hashtag_name": hashtag_name,
                "related_hashtags_count": len(hashtags_data),
                "related_hashtags": hashtags_data
            }

            self.logger.log_action("related_hashtags", {
                "hashtag": hashtag_name,
                "related_count": len(hashtags_data)
            })

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des hashtags liés à {hashtag_name}: {str(e)}")
            raise

    def like_hashtag_posts(self, hashtag_name: str, count: int = 5,
                          action: str = "recent", cursor: Optional[str] = None) -> Dict[str, Any]:
        """
        Liker des posts d'un hashtag

        Args:
            hashtag_name: Nom du hashtag (sans #)
            count: Nombre de posts à liker
            action: Type d'action ("recent", "top")
            cursor: Curseur pour la pagination

        Returns:
            Résultat des likes
        """
        try:
            # Récupérer les posts
            posts_data = self.get_hashtag_posts(hashtag_name, action, count * 2, cursor)
            posts = posts_data["posts"]

            # Filtrer les posts non likés
            available_posts = [post for post in posts if not post.has_liked]

            if not available_posts:
                self.logger.log_info(f"Aucun post disponible à liker pour le hashtag {hashtag_name}")
                return {
                    "hashtag": hashtag_name,
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
                        "owner_username": post.owner_username,
                        "liked_at": self.client.get_current_timestamp()
                    })

                    self.logger.log_action("hashtag_like", {
                        "hashtag": hashtag_name,
                        "media_id": post.media_id,
                        "owner_username": post.owner_username
                    })

                except Exception as e:
                    self.logger.log_error(f"Erreur lors du like du post {post.media_id}: {str(e)}")

            result = {
                "hashtag": hashtag_name,
                "likes_requested": count,
                "likes_successful": len(liked_posts),
                "available_posts": len(available_posts),
                "liked_posts": liked_posts,
                "next_cursor": posts_data["next_cursor"]
            }

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors du like des posts du hashtag {hashtag_name}: {str(e)}")
            raise

    def _clean_hashtag_name(self, hashtag_name: str) -> str:
        """Nettoyer le nom du hashtag"""
        if not hashtag_name:
            raise ValueError("Le nom du hashtag ne peut pas être vide")

        # Enlever le # si présent
        if hashtag_name.startswith("#"):
            hashtag_name = hashtag_name[1:]

        return hashtag_name.strip()
