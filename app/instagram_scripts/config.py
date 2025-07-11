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

    # Limites de sécurité
    MAX_LIKES_PER_SESSION = 50
    MAX_MESSAGES_PER_SESSION = 10
    MAX_FOLLOWERS_PER_REQUEST = 200
    MAX_POSTS_PER_REQUEST = 100

    # Délais entre les actions (en secondes)
    DELAY_BETWEEN_LIKES = (30, 60)  # Min, Max
    DELAY_BETWEEN_MESSAGES = (60, 120)
    DELAY_BETWEEN_REQUESTS = (5, 10)

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
        """Obtenir les limites de taux"""
        return {
            "likes_per_hour": 30,
            "likes_per_day": 150,
            "messages_per_hour": 10,
            "messages_per_day": 50,
            "follows_per_hour": 20,
            "follows_per_day": 100,
            "unfollows_per_hour": 20,
            "unfollows_per_day": 100
        }

    @classmethod
    def get_delays(cls) -> Dict[str, tuple]:
        """Obtenir les délais entre actions"""
        return {
            "likes": cls.DELAY_BETWEEN_LIKES,
            "messages": cls.DELAY_BETWEEN_MESSAGES,
            "requests": cls.DELAY_BETWEEN_REQUESTS
        }

    @classmethod
    def get_limits(cls) -> Dict[str, int]:
        """Obtenir les limites de sécurité"""
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
