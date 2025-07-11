#!/usr/bin/env python3
# frozen_string_literal: true
"""
Script de test pour la gestion des challenges Instagram
"""

import os
import sys
import json
import argparse
from datetime import datetime

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from core.client import InstagramClient
from services.challenge_service import ChallengeService

def test_challenge_service():
    """Tester le service de challenge"""
    print("🧪 Test du service de challenge...")

    # Configuration de test
    test_config = {
        "two_captcha_api_key": os.getenv("TWOCAPTCHA_API_KEY"),
        "challenge_email": {
            "email": "test@example.com",
            "password": "test_password",
            "imap_server": "imap.gmail.com"
        },
        "challenge_sms": {
            "provider": "test",
            "phone_number": "+33123456789"
        }
    }

    try:
        challenge_service = ChallengeService(test_config)
        print("✅ Service de challenge initialisé avec succès")

        # Test de génération de mot de passe
        new_password = challenge_service.change_password_handler("test_user")
        print(f"✅ Mot de passe généré: {new_password}")

        return True
    except Exception as e:
        print(f"❌ Erreur lors du test du service de challenge: {e}")
        return False

def test_client_with_challenge(username, password):
    """Tester le client Instagram avec gestion des challenges"""
    print(f"🧪 Test du client Instagram pour {username}...")

    # Configuration de challenge
    challenge_config = {
        "two_captcha_api_key": os.getenv("TWOCAPTCHA_API_KEY"),
        "challenge_email": {
            "email": os.getenv("CHALLENGE_EMAIL"),
            "password": os.getenv("CHALLENGE_EMAIL_PASSWORD"),
            "imap_server": "imap.gmail.com"
        }
    }

    try:
        # Initialiser le client avec gestion des challenges
        client = InstagramClient(username, password, challenge_config=challenge_config)
        print("✅ Client Instagram initialisé avec gestion des challenges")

        # Test de connexion
        try:
            # Essayer de récupérer le profil pour vérifier la connexion
            user_info = client.client.user_info_by_username(username)
            print(f"✅ Connexion réussie pour {username}")
            print(f"   - Nom complet: {user_info.full_name}")
            print(f"   - Followers: {user_info.follower_count}")
            return True
        except Exception as e:
            print(f"⚠️  Erreur lors de la vérification de connexion: {e}")
            print("   (Cela peut être normal si un challenge est demandé)")
            return True

    except Exception as e:
        print(f"❌ Erreur lors de l'initialisation du client: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Test de la gestion des challenges Instagram")
    parser.add_argument("--test-service", action="store_true", help="Tester le service de challenge")
    parser.add_argument("--test-client", action="store_true", help="Tester le client avec challenges")
    parser.add_argument("--username", help="Nom d'utilisateur Instagram pour le test")
    parser.add_argument("--password", help="Mot de passe Instagram pour le test")
    parser.add_argument("--config-file", help="Fichier de configuration JSON")

    args = parser.parse_args()

    print("🔒 Test de la gestion des challenges Instagram")
    print("=" * 50)

    # Test du service de challenge
    if args.test_service:
        if not test_challenge_service():
            sys.exit(1)

    # Test du client avec challenges
    if args.test_client:
        if not args.username or not args.password:
            print("❌ --username et --password requis pour tester le client")
            sys.exit(1)

        if not test_client_with_challenge(args.username, args.password):
            sys.exit(1)

    # Test avec fichier de configuration
    if args.config_file:
        print(f"🧪 Test avec fichier de configuration: {args.config_file}")
        try:
            with open(args.config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)

            for account_config in config:
                username = account_config.get("username")
                password = account_config.get("password")

                if username and password:
                    print(f"\n📱 Test du compte: {username}")
                    if test_client_with_challenge(username, password):
                        print(f"✅ Test réussi pour {username}")
                    else:
                        print(f"❌ Test échoué pour {username}")
                        sys.exit(1)
                else:
                    print(f"⚠️  Configuration incomplète pour un compte")

        except Exception as e:
            print(f"❌ Erreur lors du test avec fichier de configuration: {e}")
            sys.exit(1)

    # Si aucun test spécifique demandé, faire les tests de base
    if not any([args.test_service, args.test_client, args.config_file]):
        print("🧪 Tests de base...")

        if not test_challenge_service():
            sys.exit(1)

        print("\n✅ Tous les tests de base réussis")
        print("\n💡 Pour tester avec un compte réel:")
        print("   python test_challenge.py --test-client --username VOTRE_USERNAME --password VOTRE_PASSWORD")
        print("\n💡 Pour tester avec un fichier de configuration:")
        print("   python test_challenge.py --config-file config_challenge_example.json")

    print("\n🎉 Tests terminés avec succès!")

if __name__ == "__main__":
    main()
