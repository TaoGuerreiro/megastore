# frozen_string_literal: true
"""
Client Instagram de base avec gestion d'authentification et utilitaires
"""

import os
import json
import logging
import uuid
import random
from datetime import datetime
from typing import Optional, Dict, Any, List, Union
from dataclasses import dataclass, asdict
from instagrapi import Client
from instagrapi.exceptions import LoginRequired

# Import du service de challenge
try:
    from services.challenge_service import ChallengeService
    CHALLENGE_SERVICE_AVAILABLE = True
except ImportError:
    CHALLENGE_SERVICE_AVAILABLE = False


@dataclass
class MediaInfo:
    """Informations formatées d'un média Instagram"""
    media_id: str
    media_code: Optional[str]
    media_type: Optional[str]
    like_count: int
    comment_count: int
    caption_text: Optional[str]
    taken_at: Optional[str]
    has_liked: bool
    owner_id: Optional[str]
    owner_username: Optional[str]


@dataclass
class UserInfo:
    """Informations formatées d'un utilisateur Instagram"""
    user_id: str
    username: Optional[str]
    full_name: Optional[str]
    is_private: bool
    is_verified: bool
    profile_pic_url: Optional[str]
    follower_count: int
    following_count: int
    media_count: int
    biography: Optional[str]
    external_url: Optional[str]


class InstagramClient:
    """Client Instagram avec gestion d'authentification et méthodes utilitaires"""

    def __init__(self, username: str, password: str, session_dir: str = "sessions", challenge_config: Optional[Dict[str, Any]] = None):
        """
        Initialiser le client Instagram

        Args:
            username: Nom d'utilisateur Instagram
            password: Mot de passe Instagram
            session_dir: Répertoire pour sauvegarder les sessions
            challenge_config: Configuration pour la gestion des challenges
        """
        self.username = username
        self.password = password
        self.client = Client()
        self.session_dir = session_dir
        self.challenge_config = challenge_config or {}

        # Créer le répertoire de sessions s'il n'existe pas
        os.makedirs(session_dir, exist_ok=True)

        # Configurer les métadonnées pour être plus naturelles
        self._setup_natural_metadata()

        # Configurer le logging
        self._setup_logging()

        # Configurer les handlers de challenge
        self._setup_challenge_handlers()

        # Authentification
        self._authenticate()

    def _setup_natural_metadata(self):
        """Configurer les métadonnées pour être plus naturelles et éviter les détections"""
        # Générer des UUIDs aléatoires mais cohérents pour cette session
        session_uuids = self._generate_session_uuids()

        # Configuration d'appareil réaliste (OnePlus 6T)
        device_config = self._get_natural_device_config()

        # User-Agent réaliste pour iPhone
        user_agent = f"Instagram {device_config['app_version']} iOS ({device_config['ios_version']}/{device_config['ios_release']}; {device_config['dpi']}; {device_config['resolution']}; {device_config['manufacturer']}; {device_config['device']}; {device_config['model']}; {device_config['cpu']}; fr_FR; {device_config['version_code']})"

        # Configuration des paramètres de requête
        nantes_offset = self._get_nantes_timezone_offset()

        settings = {
            "uuids": session_uuids,
            "mid": "aGvTYwABAAFtwoS1UAy4mvV_jEU4",
            "ig_u_rur": None,
            "ig_www_claim": None,
            "cookies": {},
            "last_login": None,
            "device_settings": device_config,
            "user_agent": user_agent,
            "country": "FR",
            "country_code": 33,
            "locale": "fr_FR",
            "timezone_offset": nantes_offset
        }

        # Appliquer les configurations
        self.client.set_device(device_config)
        self.client.set_user_agent(user_agent)
        self.client.set_locale("fr_FR")
        self.client.set_country("FR")
        self.client.set_timezone_offset(nantes_offset)
        self.client.set_settings(settings)

    def _generate_session_uuids(self) -> Dict[str, str]:
        """Générer des UUIDs aléatoires mais cohérents pour cette session"""
        # Utiliser un seed basé sur le username pour avoir des UUIDs cohérents
        random.seed(hash(self.username) % 2**32)

        return {
            "phone_id": str(uuid.uuid4()),
            "uuid": str(uuid.uuid4()),
            "client_session_id": str(uuid.uuid4()),
            "advertising_id": str(uuid.uuid4()),
            "android_device_id": f"android-{uuid.uuid4().hex[:16]}",
            "request_id": str(uuid.uuid4()),
            "tray_session_id": str(uuid.uuid4())
        }

    def _get_nantes_timezone_offset(self) -> int:
        """Obtenir le timezone offset pour Nantes (heure d'été/hiver)"""
        from datetime import datetime

        # Heure d'été en France : UTC+2 (mars à octobre)
        # Heure d'hiver en France : UTC+1 (octobre à mars)

        now = datetime.now()

        # Règle simplifiée : heure d'été de mars à octobre
        # En réalité, les dates exactes varient selon les années
        if now.month >= 3 and now.month <= 10:
            return 7200  # UTC+2 (heure d'été)
        else:
            return 3600  # UTC+1 (heure d'hiver)

    def _get_natural_device_config(self) -> Dict[str, Any]:
        """Obtenir une configuration d'appareil naturelle avec variations"""
        # Utiliser un seed basé sur le username pour avoir des variations cohérentes
        random.seed(hash(self.username) % 2**32)

        # Configuration iPhone 13 pour Nantes
        iphone_configs = [
            {
                "app_version": "269.0.0.18.75",
                "ios_version": 17,
                "ios_release": "17.0.0",
                "dpi": "460dpi",
                "resolution": "1170x2532",
                "manufacturer": "Apple",
                "device": "iPhone14,2",
                "model": "iPhone 13",
                "cpu": "apple",
                "version_code": "314665256"
            },
            {
                "app_version": "268.0.0.18.74",
                "ios_version": 17,
                "ios_release": "17.1.0",
                "dpi": "460dpi",
                "resolution": "1170x2532",
                "manufacturer": "Apple",
                "device": "iPhone14,2",
                "model": "iPhone 13",
                "cpu": "apple",
                "version_code": "314665256"
            },
            {
                "app_version": "267.0.0.18.73",
                "ios_version": 16,
                "ios_release": "16.6.0",
                "dpi": "460dpi",
                "resolution": "1170x2532",
                "manufacturer": "Apple",
                "device": "iPhone14,2",
                "model": "iPhone 13",
                "cpu": "apple",
                "version_code": "314665256"
            }
        ]

        return random.choice(iphone_configs)

    def _setup_logging(self):
        """Configurer le système de logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(f"InstagramClient.{self.username}")

    def _setup_challenge_handlers(self):
        """Configurer les handlers de challenge si le service est disponible"""
        if CHALLENGE_SERVICE_AVAILABLE and self.challenge_config:
            try:
                challenge_service = ChallengeService(self.challenge_config)
                challenge_service.setup_challenge_handlers(self.client)
                self.logger.info("Handlers de challenge configurés")
            except Exception as e:
                self.logger.warning(f"Impossible de configurer les handlers de challenge: {e}")
        else:
            if not CHALLENGE_SERVICE_AVAILABLE:
                self.logger.warning("Service de challenge non disponible")
            if not self.challenge_config:
                self.logger.info("Aucune configuration de challenge fournie")

    def _get_session_path(self) -> str:
        """Obtenir le chemin du fichier de session"""
        return os.path.join(self.session_dir, f"session_{self.username}.json")

    def _authenticate(self):
        """Authentification avec gestion de session"""
        session_path = self._get_session_path()

        # Essayer de charger la session existante
        if os.path.exists(session_path):
            try:
                self.client.load_settings(session_path)
                self.client.login(self.username, self.password)

                # Vérifier que la session est valide
                try:
                    self.client.get_timeline_feed()
                    self.logger.info("Authentification réussie via session existante")
                    return
                except LoginRequired:
                    self.logger.warning("Session expirée, nouvelle authentification requise")
            except Exception as e:
                self.logger.warning(f"Erreur lors du chargement de la session: {e}")

        # Authentification avec mot de passe
        try:
            if self.client.login(self.username, self.password):
                self.client.dump_settings(session_path)
                self.logger.info("Authentification réussie avec mot de passe")
            else:
                raise Exception("Échec de l'authentification")
        except Exception as e:
            raise Exception(f"Impossible de se connecter à Instagram: {str(e)}")

    def validate_user_id(self, user_id: Union[str, int]) -> int:
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

    def validate_username(self, username: str) -> str:
        """Valider et nettoyer un username"""
        if not username:
            raise ValueError("username ne peut pas être vide")

        # Enlever le @ si présent
        if username.startswith("@"):
            username = username[1:]

        return username.strip()

    def get_user_id_from_username(self, username: str) -> int:
        """Récupérer l'ID utilisateur à partir du username"""
        username = self.validate_username(username)
        try:
            return self.client.user_id_from_username(username)
        except Exception as e:
            raise Exception(f"Impossible de trouver l'utilisateur {username}: {str(e)}")

    def get_user_medias(self, user_id: Union[str, int], amount: int = 20) -> List[Any]:
        """Récupérer les médias d'un utilisateur avec fallback API"""
        user_id = self.validate_user_id(user_id)

        try:
            # Essayer l'API publique d'abord
            return self.client.user_medias_gql(user_id, amount=amount)
        except Exception as e:
            self.logger.warning(f"API publique échouée, tentative API privée: {e}")
            try:
                return self.client.user_medias_v1(user_id, amount=amount)
            except Exception as e2:
                raise Exception(f"Impossible de récupérer les publications: {str(e2)}")

    def format_media_info(self, media: Any) -> MediaInfo:
        """Formater les informations d'un média"""
        try:
            return MediaInfo(
                media_id=str(media.id),
                media_code=getattr(media, 'code', None),
                media_type=getattr(media, 'media_type', None),
                like_count=getattr(media, 'like_count', 0),
                comment_count=getattr(media, 'comment_count', 0),
                caption_text=self._truncate_text(getattr(media, 'caption_text', None), 100),
                taken_at=str(media.taken_at) if getattr(media, 'taken_at', None) else None,
                has_liked=getattr(media, 'has_liked', False),
                owner_id=str(media.user.pk) if hasattr(media, 'user') and media.user else None,
                owner_username=getattr(media.user, 'username', None) if hasattr(media, 'user') and media.user else None
            )
        except Exception as e:
            self.logger.error(f"Erreur formatage média: {e}")
            raise

    def format_user_info(self, user: Any) -> UserInfo:
        """Formater les informations d'un utilisateur"""
        try:
            profile_pic_url = getattr(user, 'profile_pic_url', None)
            external_url = getattr(user, 'external_url', None)

            return UserInfo(
                user_id=str(user.pk),
                username=getattr(user, 'username', None),
                full_name=getattr(user, 'full_name', None),
                is_private=getattr(user, 'is_private', False),
                is_verified=getattr(user, 'is_verified', False),
                profile_pic_url=str(profile_pic_url) if profile_pic_url else None,
                follower_count=getattr(user, 'follower_count', 0),
                following_count=getattr(user, 'following_count', 0),
                media_count=getattr(user, 'media_count', 0),
                biography=getattr(user, 'biography', None),
                external_url=str(external_url) if external_url else None
            )
        except Exception as e:
            self.logger.error(f"Erreur formatage utilisateur: {e}")
            raise

    def _truncate_text(self, text: Optional[str], max_length: int) -> Optional[str]:
        """Tronquer un texte avec des points de suspension"""
        if text and len(text) > max_length:
            return text[:max_length] + "..."
        return text

    def get_current_timestamp(self) -> str:
        """Obtenir l'horodatage actuel"""
        return datetime.utcnow().isoformat()

    def to_dict(self, obj: Any) -> Dict[str, Any]:
        """Convertir un objet dataclass en dictionnaire"""
        if hasattr(obj, '__dataclass_fields__'):
            return asdict(obj)
        return obj

    def print_json_result(self, result: Any):
        """Afficher un résultat en JSON"""
        if hasattr(result, '__dataclass_fields__'):
            result = asdict(result)
        print(json.dumps(result, ensure_ascii=False, indent=2))

    def print_error(self, error_message: str):
        """Afficher une erreur en JSON"""
        self.print_json_result({"error": error_message})
