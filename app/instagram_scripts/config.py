# frozen_string_literal: true
"""
Configuration centralisée pour les scripts Instagram
"""

import os
from typing import Dict, Any


class InstagramConfig:
    """Configuration pour les scripts Instagram"""

    # Répertoires par défaut
    DEFAULT_LOG_DIR = "logs"
    DEFAULT_SESSION_DIR = "sessions"
    DEFAULT_STATS_DIR = "stats"

    # Limites de sécurité - RÉDUITES POUR ÉVITER LES CHALLENGES
    MAX_LIKES_PER_SESSION = 20  # Réduit de 50 à 20
    MAX_MESSAGES_PER_SESSION = 5  # Réduit de 10 à 5
    MAX_FOLLOWERS_PER_REQUEST = 50  # Réduit de 200 à 50
    MAX_POSTS_PER_REQUEST = 20  # Réduit de 100 à 20

    # Délais entre les actions (en secondes) - AUGMENTÉS
    DELAY_BETWEEN_LIKES = (120, 300)  # 2-5 minutes (au lieu de 30-60s)
    DELAY_BETWEEN_MESSAGES = (300, 600)  # 5-10 minutes (au lieu de 60-120s)
    DELAY_BETWEEN_REQUESTS = (10, 30)  # 10-30 secondes (au lieu de 5-10s)

    # Timeouts
    REQUEST_TIMEOUT = 30
    SESSION_TIMEOUT = 3600  # 1 heure

    # API Configuration
    API_URL = os.environ.get("SOCIAL_CAMPAIGN_API_URL", "http://localhost:3000")
    API_TOKEN = os.environ.get("SOCIAL_CAMPAIGN_API_TOKEN")
    CAMPAIGN_ID = os.environ.get("SOCIAL_CAMPAIGN_ID")

    # Logging
    LOG_LEVEL = os.environ.get("INSTAGRAM_LOG_LEVEL", "INFO")
    LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

    @classmethod
    def get_rate_limits(cls) -> Dict[str, Any]:
        """Obtenir les limites de taux - ÉQUILIBRÉES POUR SÉCURITÉ ET EFFICACITÉ"""
        return {
            "likes_per_hour": 15,     # Augmenté de 8 à 15 (plus réaliste)
            "likes_per_day": 80,      # Augmenté de 30 à 80 (plus réaliste)
            "messages_per_hour": 5,   # Augmenté de 3 à 5
            "messages_per_day": 25,   # Augmenté de 15 à 25
            "follows_per_hour": 8,    # Augmenté de 5 à 8
            "follows_per_day": 40,    # Augmenté de 20 à 40
            "unfollows_per_hour": 8,  # Augmenté de 5 à 8
            "unfollows_per_day": 40   # Augmenté de 20 à 40
        }

    @classmethod
    def get_delays(cls) -> Dict[str, tuple]:
        """Obtenir les délais entre actions - AUGMENTÉS"""
        return {
            "likes": cls.DELAY_BETWEEN_LIKES,
            "messages": cls.DELAY_BETWEEN_MESSAGES,
            "requests": cls.DELAY_BETWEEN_REQUESTS
        }

    @classmethod
    def get_limits(cls) -> Dict[str, int]:
        """Obtenir les limites de sécurité - RÉDUITES"""
        return {
            "max_likes_per_session": cls.MAX_LIKES_PER_SESSION,
            "max_messages_per_session": cls.MAX_MESSAGES_PER_SESSION,
            "max_followers_per_request": cls.MAX_FOLLOWERS_PER_REQUEST,
            "max_posts_per_request": cls.MAX_POSTS_PER_REQUEST
        }

    @classmethod
    def validate_credentials(cls, username: str, password: str) -> bool:
        """Valider les credentials"""
        if not username or not password:
            return False
        if len(username) < 3 or len(password) < 6:
            return False
        return True

    @classmethod
    def get_user_agent(cls) -> str:
        """Obtenir le User-Agent pour les requêtes"""
        return "Instagram 219.0.0.12.117 Android (30/11; 420dpi; 1080x2400; samsung; SM-G991B; o1s; qcom; fr_FR; 314665256)"

    @classmethod
    def get_device_settings(cls) -> Dict[str, Any]:
        """Obtenir les paramètres d'appareil"""
        return {
            "app_version": "219.0.0.12.117",
            "android_version": 30,
            "android_release": "11",
            "dpi": "420dpi",
            "resolution": "1080x2400",
            "manufacturer": "samsung",
            "device": "SM-G991B",
            "model": "o1s",
            "cpu": "qcom",
            "version_code": "314665256"
        }
