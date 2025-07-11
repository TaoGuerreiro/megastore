#!/usr/bin/env python3
# frozen_string_literal: true
"""
Service de gestion des challenges Instagram (CAPTCHA, SMS, Email)
"""

import os
import re
import time
import logging
import imaplib
import email
from typing import Optional, Dict, Any
from instagrapi.mixins.challenge import ChallengeChoice

try:
    from twocaptcha import TwoCaptcha
    TWOCAPTCHA_AVAILABLE = True
except ImportError:
    TWOCAPTCHA_AVAILABLE = False
    print("⚠️  2captcha-python non installé. Installation: pip install 2captcha-python")


class ChallengeService:
    """Service de gestion automatique des challenges Instagram"""

    def __init__(self, config: Dict[str, Any]):
        """
        Initialiser le service de challenge

        Args:
            config: Configuration contenant les paramètres de challenge
        """
        self.config = config
        self.logger = logging.getLogger("ChallengeService")

        # Configuration 2captcha
        self.two_captcha_api_key = config.get("two_captcha_api_key")
        if self.two_captcha_api_key and TWOCAPTCHA_AVAILABLE:
            self.solver = TwoCaptcha(self.two_captcha_api_key)
        else:
            self.solver = None
            if not TWOCAPTCHA_AVAILABLE:
                self.logger.warning("2captcha-python non installé. CAPTCHA manuel requis.")
            elif not self.two_captcha_api_key:
                self.logger.warning("Clé API 2captcha non configurée. CAPTCHA manuel requis.")

        # Configuration email pour les codes
        self.email_config = config.get("challenge_email", {})
        self.sms_config = config.get("challenge_sms", {})

    def challenge_code_handler(self, username: str, choice: ChallengeChoice) -> Optional[str]:
        """
        Handler principal pour tous les types de challenges

        Args:
            username: Nom d'utilisateur Instagram
            choice: Type de challenge demandé par Instagram

        Returns:
            Code de résolution ou None si échec
        """
        self.logger.info(f"Challenge détecté pour {username}: {choice}")

        try:
            if choice == ChallengeChoice.SMS:
                return self._get_code_from_sms(username)
            elif choice == ChallengeChoice.EMAIL:
                return self._get_code_from_email(username)
            elif choice == ChallengeChoice.CAPTCHA:
                return self._solve_captcha(username)
            else:
                self.logger.warning(f"Type de challenge non géré: {choice}")
                return None
        except Exception as e:
            self.logger.error(f"Erreur lors de la résolution du challenge {choice}: {e}")
            return None

    def change_password_handler(self, username: str) -> str:
        """
        Handler pour le changement de mot de passe forcé

        Args:
            username: Nom d'utilisateur Instagram

        Returns:
            Nouveau mot de passe généré
        """
        import random
        import string

        # Générer un mot de passe sécurisé
        chars = string.ascii_letters + string.digits + "!@#$%^&*"
        new_password = ''.join(random.choice(chars) for _ in range(12))

        self.logger.info(f"Nouveau mot de passe généré pour {username}")
        return new_password

    def _get_code_from_email(self, username: str) -> Optional[str]:
        """
        Récupérer le code de vérification depuis l'email

        Args:
            username: Nom d'utilisateur Instagram

        Returns:
            Code à 6 chiffres ou None
        """
        if not self.email_config:
            self.logger.error("Configuration email manquante pour la récupération de code")
            return None

        try:
            # Connexion IMAP
            mail = imaplib.IMAP4_SSL(self.email_config.get("imap_server", "imap.gmail.com"))
            mail.login(self.email_config["email"], self.email_config["password"])
            mail.select("inbox")

            # Rechercher les emails non lus
            result, data = mail.search(None, "(UNSEEN)")
            if result != "OK":
                self.logger.error("Erreur lors de la recherche d'emails")
                return None

            email_ids = data[0].split()

            # Parcourir les emails récents (du plus récent au plus ancien)
            for email_id in reversed(email_ids):
                result, data = mail.fetch(email_id, "(RFC822)")
                if result != "OK":
                    continue

                msg = email.message_from_bytes(data[0][1])

                # Extraire le contenu de l'email
                body = self._extract_email_body(msg)

                # Chercher un code à 6 chiffres
                code_match = re.search(r'\b(\d{6})\b', body)
                if code_match:
                    code = code_match.group(1)
                    self.logger.info(f"Code trouvé dans l'email: {code}")

                    # Marquer l'email comme lu
                    mail.store(email_id, "+FLAGS", "\\Seen")
                    mail.close()
                    mail.logout()

                    return code

            mail.close()
            mail.logout()
            self.logger.warning("Aucun code trouvé dans les emails récents")
            return None

        except Exception as e:
            self.logger.error(f"Erreur lors de la récupération du code email: {e}")
            return None

    def _extract_email_body(self, msg: email.message.Message) -> str:
        """Extraire le contenu texte d'un email"""
        body = ""

        if msg.is_multipart():
            for part in msg.walk():
                if part.get_content_type() == "text/plain":
                    try:
                        body += part.get_payload(decode=True).decode('utf-8', errors='ignore')
                    except:
                        pass
        else:
            try:
                body = msg.get_payload(decode=True).decode('utf-8', errors='ignore')
            except:
                pass

        return body

    def _get_code_from_sms(self, username: str) -> Optional[str]:
        """
        Récupérer le code de vérification depuis SMS
        Note: Nécessite une configuration spécifique selon le fournisseur

        Args:
            username: Nom d'utilisateur Instagram

        Returns:
            Code à 6 chiffres ou None
        """
        if not self.sms_config:
            self.logger.error("Configuration SMS manquante pour la récupération de code")
            return None

        # Implémentation dépend du service SMS utilisé
        # Exemple avec Twilio ou autre service
        try:
            # TODO: Implémenter selon le service SMS configuré
            self.logger.warning("Récupération SMS non implémentée")
            return None
        except Exception as e:
            self.logger.error(f"Erreur lors de la récupération du code SMS: {e}")
            return None

    def _solve_captcha(self, username: str) -> Optional[str]:
        """
        Résoudre automatiquement un CAPTCHA

        Args:
            username: Nom d'utilisateur Instagram

        Returns:
            Solution du CAPTCHA ou None
        """
        if not self.solver:
            self.logger.warning("Service de résolution CAPTCHA non disponible")
            return self._manual_captcha_solve(username)

        try:
            # Note: instagrapi gère automatiquement la récupération de l'image CAPTCHA
            # Cette méthode sera appelée par instagrapi quand il a besoin de résoudre un CAPTCHA

            # Pour les CAPTCHA reCAPTCHA
            if hasattr(self, 'recaptcha_sitekey') and hasattr(self, 'recaptcha_url'):
                result = self.solver.recaptcha(
                    sitekey=self.recaptcha_sitekey,
                    url=self.recaptcha_url
                )
                return result['code']

            # Pour les CAPTCHA image classiques
            # (instagrapi gère automatiquement la récupération de l'image)
            self.logger.info("CAPTCHA détecté, résolution automatique en cours...")

            # Retourner None pour que instagrapi utilise sa résolution automatique
            # ou implémenter une logique spécifique selon le type de CAPTCHA
            return None

        except Exception as e:
            self.logger.error(f"Erreur lors de la résolution automatique du CAPTCHA: {e}")
            return self._manual_captcha_solve(username)

    def _manual_captcha_solve(self, username: str) -> Optional[str]:
        """
        Résolution manuelle du CAPTCHA (fallback)

        Args:
            username: Nom d'utilisateur Instagram

        Returns:
            Solution du CAPTCHA saisie manuellement
        """
        print(f"\n🔒 CAPTCHA détecté pour {username}!")
        print("Veuillez résoudre le CAPTCHA manuellement dans votre navigateur.")
        print("1. Ouvrez Instagram dans votre navigateur")
        print("2. Connectez-vous avec le compte concerné")
        print("3. Résolvez le CAPTCHA affiché")
        print("4. Une fois résolu, le script continuera automatiquement")

        # Attendre que l'utilisateur résolve le CAPTCHA
        input("Appuyez sur Entrée une fois le CAPTCHA résolu...")

        return "MANUAL_RESOLVED"

    def setup_challenge_handlers(self, client):
        """
        Configurer les handlers de challenge sur le client instagrapi

        Args:
            client: Instance du client instagrapi
        """
        client.challenge_code_handler = self.challenge_code_handler
        client.change_password_handler = self.change_password_handler

        self.logger.info("Handlers de challenge configurés sur le client")
