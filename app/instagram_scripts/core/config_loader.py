# frozen_string_literal: true
"""
Module de configuration unifié pour les scripts Instagram
"""

import os
import json
import argparse
from typing import Dict, Any, Optional, Union
from pathlib import Path


class ConfigLoader:
    """Chargeur de configuration unifié pour les scripts Instagram"""

    @staticmethod
    def load_from_args(username: str, password: str, challenge_config: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Charger la configuration depuis les arguments de ligne de commande

        Args:
            username: Nom d'utilisateur Instagram
            password: Mot de passe Instagram
            challenge_config: Configuration des challenges (optionnel)

        Returns:
            Configuration complète
        """
        config = {
            "username": username,
            "password": password,
            "challenge_config": challenge_config or {}
        }

        # Ajouter les variables d'environnement si disponibles
        ConfigLoader._add_environment_vars(config)

        return config

    @staticmethod
    def load_from_file(config_file: str) -> Dict[str, Any]:
        """
        Charger la configuration depuis un fichier JSON

        Args:
            config_file: Chemin vers le fichier de configuration

        Returns:
            Configuration complète
        """
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)
        except FileNotFoundError:
            raise ValueError(f"Fichier de configuration non trouvé: {config_file}")
        except json.JSONDecodeError as e:
            raise ValueError(f"Erreur de format JSON dans {config_file}: {e}")

        # Validation de base
        if not config.get("username") or not config.get("password"):
            raise ValueError("Username et password requis dans le fichier de configuration")

        # Ajouter les variables d'environnement si disponibles
        ConfigLoader._add_environment_vars(config)

        return config

    @staticmethod
    def load_from_env() -> Dict[str, Any]:
        """
        Charger la configuration depuis les variables d'environnement

        Returns:
            Configuration complète
        """
        username = os.getenv("INSTAGRAM_USERNAME")
        password = os.getenv("INSTAGRAM_PASSWORD")

        if not username or not password:
            raise ValueError("Variables d'environnement INSTAGRAM_USERNAME et INSTAGRAM_PASSWORD requises")

        config = {
            "username": username,
            "password": password,
            "challenge_config": {}
        }

        # Ajouter les variables d'environnement si disponibles
        ConfigLoader._add_environment_vars(config)

        return config

    @staticmethod
    def _add_environment_vars(config: Dict[str, Any]):
        """Ajouter les variables d'environnement à la configuration"""

        # Configuration 2captcha
        two_captcha_key = os.getenv("TWOCAPTCHA_API_KEY")
        if two_captcha_key and "challenge_config" not in config:
            config["challenge_config"] = {}
        if two_captcha_key:
            config["challenge_config"]["two_captcha_api_key"] = two_captcha_key

        # Configuration email
        challenge_email = os.getenv("CHALLENGE_EMAIL")
        challenge_email_password = os.getenv("CHALLENGE_EMAIL_PASSWORD")
        if challenge_email and challenge_email_password:
            if "challenge_config" not in config:
                config["challenge_config"] = {}
            if "challenge_email" not in config["challenge_config"]:
                config["challenge_config"]["challenge_email"] = {}

            config["challenge_config"]["challenge_email"].update({
                "email": challenge_email,
                "password": challenge_email_password,
                "imap_server": os.getenv("CHALLENGE_EMAIL_IMAP", "imap.gmail.com")
            })

        # Configuration SMS
        challenge_sms_phone = os.getenv("CHALLENGE_SMS_PHONE")
        if challenge_sms_phone:
            if "challenge_config" not in config:
                config["challenge_config"] = {}
            if "challenge_sms" not in config["challenge_config"]:
                config["challenge_config"]["challenge_sms"] = {}

            config["challenge_config"]["challenge_sms"].update({
                "phone_number": challenge_sms_phone,
                "provider": os.getenv("CHALLENGE_SMS_PROVIDER", "twilio"),
                "account_sid": os.getenv("CHALLENGE_SMS_ACCOUNT_SID"),
                "auth_token": os.getenv("CHALLENGE_SMS_AUTH_TOKEN")
            })

    @staticmethod
    def validate_config(config: Dict[str, Any]) -> bool:
        """
        Valider une configuration

        Args:
            config: Configuration à valider

        Returns:
            True si la configuration est valide
        """
        required_fields = ["username", "password"]

        for field in required_fields:
            if not config.get(field):
                raise ValueError(f"Champ requis manquant: {field}")

        if len(config["username"]) < 3:
            raise ValueError("Username doit contenir au moins 3 caractères")

        if len(config["password"]) < 6:
            raise ValueError("Password doit contenir au moins 6 caractères")

        return True

    @staticmethod
    def create_template_config(output_file: str = "config_template.json"):
        """
        Créer un template de configuration

        Args:
            output_file: Fichier de sortie pour le template
        """
        template = {
            "username": "votre_username_instagram",
            "password": "votre_mot_de_passe_instagram",
            "social_campagne_id": 123,
            "hashtags": [
                {
                    "hashtag": "fashion",
                    "social_target_id": 456
                },
                {
                    "hashtag": "style",
                    "social_target_id": 789
                }
            ],
            "targeted_accounts": [
                {
                    "account": "influenceur1",
                    "social_target_id": 101
                },
                {
                    "account": "influenceur2",
                    "social_target_id": 102
                }
            ],
            "challenge_config": {
                "two_captcha_api_key": "votre_cle_2captcha",
                "challenge_email": {
                    "email": "votre_email@gmail.com",
                    "password": "mot_de_passe_email",
                    "imap_server": "imap.gmail.com"
                },
                "challenge_sms": {
                    "phone_number": "+33123456789",
                    "provider": "twilio",
                    "account_sid": "votre_account_sid",
                    "auth_token": "votre_auth_token"
                }
            }
        }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(template, f, indent=2, ensure_ascii=False)

        print(f"Template de configuration créé: {output_file}")

    @staticmethod
    def add_common_args(parser: argparse.ArgumentParser, require_config: bool = False):
        """
        Ajouter les arguments communs à un parser argparse

        Args:
            parser: Parser argparse
            require_config: Si True, rend le fichier de config obligatoire
        """
        group = parser.add_mutually_exclusive_group(required=require_config)

        group.add_argument(
            "--config-file", "-c",
            help="Fichier de configuration JSON"
        )

        group.add_argument(
            "--env",
            action="store_true",
            help="Utiliser les variables d'environnement"
        )

        # Arguments pour mode direct (si pas de config-file)
        if not require_config:
            parser.add_argument(
                "--username", "-u",
                help="Nom d'utilisateur Instagram (si pas de config-file)"
            )
            parser.add_argument(
                "--password", "-p",
                help="Mot de passe Instagram (si pas de config-file)"
            )

        parser.add_argument(
            "--log-dir",
            default="logs",
            help="Répertoire de logs (défaut: logs)"
        )

    @staticmethod
    def load_config_from_args(args: argparse.Namespace) -> Dict[str, Any]:
        """
        Charger la configuration depuis les arguments argparse

        Args:
            args: Arguments parsés

        Returns:
            Configuration complète
        """
        if args.config_file:
            return ConfigLoader.load_from_file(args.config_file)
        elif args.env:
            return ConfigLoader.load_from_env()
        elif args.username and args.password:
            return ConfigLoader.load_from_args(args.username, args.password)
        else:
            raise ValueError("Configuration requise: utilisez --config-file, --env, ou --username/--password")

    @staticmethod
    def get_challenge_config(config: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Extraire la configuration de challenge

        Args:
            config: Configuration complète

        Returns:
            Configuration de challenge ou None
        """
        challenge_config = config.get("challenge_config", {})

        # Retourner None si la config est vide
        if not challenge_config:
            return None

        return challenge_config
