import os
import json
from datetime import datetime
from instagrapi import Client
from instagrapi.exceptions import LoginRequired


class BaseInstagramClient:
    def __init__(self, username, password):
        self.username = username
        self.password = password
        self.client = Client()
        self.session_path = f"session_{username}.json"
        self._authenticate()

    def _authenticate(self):
        """Authentification avec gestion de session"""
        login_via_session = False
        login_via_pw = False

        # Essayer de charger la session existante
        if os.path.exists(self.session_path):
            try:
                self.client.load_settings(self.session_path)
                self.client.login(self.username, self.password)
                try:
                    self.client.get_timeline_feed()
                except LoginRequired:
                    self.client.login(self.username, self.password)
                login_via_session = True
            except Exception as e:
                pass

        # Si la session n'a pas fonctionné, essayer avec le mot de passe
        if not login_via_session:
            try:
                if self.client.login(self.username, self.password):
                    login_via_pw = True
            except Exception as e:
                pass

        if not login_via_pw and not login_via_session:
            raise Exception("Impossible de se connecter à Instagram avec la session ou le mot de passe")

        # Sauvegarder la session
        self.client.dump_settings(self.session_path)

    def validate_user_id(self, user_id):
        """Valider un user_id"""
        if not user_id:
            raise ValueError("user_id ne peut pas être vide")

        try:
            user_id = int(user_id)
            if user_id <= 0:
                raise ValueError("user_id doit être positif")
            return user_id
        except ValueError:
            raise ValueError(f"user_id doit être un nombre valide, reçu: {user_id}")

    def validate_username(self, username):
        """Valider et nettoyer un username"""
        if not username:
            raise ValueError("username ne peut pas être vide")

        # Enlever le @ si présent
        if username.startswith("@"):
            username = username[1:]

        return username

    def get_user_id_from_username(self, username):
        """Récupérer l'ID utilisateur à partir du username"""
        username = self.validate_username(username)
        try:
            return self.client.user_id_from_username(username)
        except Exception as e:
            raise Exception(f"Impossible de trouver l'utilisateur {username}: {str(e)}")

    def get_user_medias(self, user_id, amount=20):
        """Récupérer les médias d'un utilisateur avec fallback API"""
        user_id = self.validate_user_id(user_id)

        medias = []
        try:
            # Essayer l'API publique d'abord
            medias = self.client.user_medias_gql(user_id, amount=amount)
        except Exception as e:
            # Si l'API publique échoue, essayer l'API privée
            try:
                medias = self.client.user_medias_v1(user_id, amount=amount)
            except Exception as e2:
                raise Exception(f"Impossible de récupérer les publications: {str(e2)}")

        return medias

    def format_media_info(self, media):
        """Formater les informations d'un média pour JSON"""
        try:
            return {
                "media_id": str(media.id),
                "media_code": getattr(media, 'code', None),
                "media_type": getattr(media, 'media_type', None),
                "like_count": getattr(media, 'like_count', 0),
                "comment_count": getattr(media, 'comment_count', 0),
                "caption_text": self._truncate_text(getattr(media, 'caption_text', None), 100),
                "taken_at": str(media.taken_at) if getattr(media, 'taken_at', None) else None,
                "has_liked": getattr(media, 'has_liked', False)
            }
        except Exception as e:
            return {"error": f"Erreur formatage média: {str(e)}"}

    def format_user_info(self, user):
        """Formater les informations d'un utilisateur pour JSON"""
        try:
            profile_pic_url = getattr(user, 'profile_pic_url', None)
            external_url = getattr(user, 'external_url', None)

            return {
                "user_id": str(user.pk),
                "username": getattr(user, 'username', None),
                "full_name": getattr(user, 'full_name', None),
                "is_private": getattr(user, 'is_private', False),
                "is_verified": getattr(user, 'is_verified', False),
                "profile_pic_url": str(profile_pic_url) if profile_pic_url else None,
                "follower_count": getattr(user, 'follower_count', 0),
                "following_count": getattr(user, 'following_count', 0),
                "media_count": getattr(user, 'media_count', 0),
                "biography": getattr(user, 'biography', None),
                "external_url": str(external_url) if external_url else None
            }
        except Exception as e:
            return {"error": f"Erreur formatage utilisateur: {str(e)}"}

    def _truncate_text(self, text, max_length):
        """Tronquer un texte avec des points de suspension"""
        if text and len(text) > max_length:
            return text[:max_length] + "..."
        return text

    def get_current_timestamp(self):
        """Obtenir l'horodatage actuel"""
        return str(datetime.utcnow())

    def print_json_result(self, result):
        """Afficher un résultat en JSON"""
        print(json.dumps(result, ensure_ascii=False))

    def print_error(self, error_message):
        """Afficher une erreur en JSON"""
        self.print_json_result({"error": error_message})
