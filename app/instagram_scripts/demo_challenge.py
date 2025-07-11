#!/usr/bin/env python3
# frozen_string_literal: true
"""
Démonstration de la gestion des challenges Instagram
"""

import os
import sys
import json
import time
from datetime import datetime

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from core.client import InstagramClient
from services.challenge_service import ChallengeService

def demo_challenge_service():
    """Démonstration du service de challenge"""
    print("🎭 Démonstration du service de challenge")
    print("=" * 50)

    # Configuration de démonstration
    demo_config = {
        "two_captcha_api_key": os.getenv("TWOCAPTCHA_API_KEY"),
        "challenge_email": {
            "email": "demo@example.com",
            "password": "demo_password",
            "imap_server": "imap.gmail.com"
        }
    }

    # Initialiser le service
    challenge_service = ChallengeService(demo_config)
    print("✅ Service de challenge initialisé")

    # Simuler différents types de challenges
    print("\n🔍 Simulation des différents types de challenges:")

    # Test de génération de mot de passe
    new_password = challenge_service.change_password_handler("demo_user")
    print(f"   📝 Changement de mot de passe: {new_password}")

    # Test de résolution manuelle de CAPTCHA
    print("   🔒 CAPTCHA: Mode manuel activé (fallback)")

    print("\n✅ Démonstration terminée")

def demo_client_with_challenges():
    """Démonstration du client avec gestion des challenges"""
    print("\n🎭 Démonstration du client Instagram avec challenges")
    print("=" * 50)

    # Demander les identifiants de test
    username = input("Nom d'utilisateur Instagram (ou 'demo' pour simuler): ").strip()
    if username.lower() == 'demo':
        username = "demo_user"
        password = "demo_password"
        print("   Mode simulation activé")
    else:
        password = input("Mot de passe Instagram: ").strip()

    # Configuration de challenge
    challenge_config = {
        "two_captcha_api_key": os.getenv("TWOCAPTCHA_API_KEY"),
        "challenge_email": {
            "email": os.getenv("CHALLENGE_EMAIL", "demo@example.com"),
            "password": os.getenv("CHALLENGE_EMAIL_PASSWORD", "demo_password"),
            "imap_server": "imap.gmail.com"
        }
    }

    print(f"\n🔧 Configuration de challenge:")
    print(f"   - 2captcha: {'✅ Configuré' if challenge_config['two_captcha_api_key'] else '❌ Non configuré'}")
    print(f"   - Email: {'✅ Configuré' if challenge_config['challenge_email']['email'] != 'demo@example.com' else '❌ Non configuré'}")

    try:
        print(f"\n🚀 Initialisation du client pour {username}...")
        client = InstagramClient(username, password, challenge_config=challenge_config)
        print("✅ Client initialisé avec gestion des challenges")

        if username != "demo_user":
            # Test de connexion réelle
            try:
                user_info = client.client.user_info_by_username(username)
                print(f"✅ Connexion réussie!")
                print(f"   - Nom: {user_info.full_name}")
                print(f"   - Followers: {user_info.follower_count}")
            except Exception as e:
                print(f"⚠️  Erreur de connexion: {e}")
                print("   (Cela peut être normal si un challenge est demandé)")

    except Exception as e:
        print(f"❌ Erreur lors de l'initialisation: {e}")
        return False

    return True

def demo_configuration_file():
    """Démonstration avec fichier de configuration"""
    print("\n🎭 Démonstration avec fichier de configuration")
    print("=" * 50)

    config_file = "config_challenge_example.json"

    if not os.path.exists(config_file):
        print(f"❌ Fichier {config_file} non trouvé")
        return False

    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)

        print(f"✅ Fichier de configuration chargé: {len(config)} compte(s)")

        for i, account_config in enumerate(config, 1):
            username = account_config.get("username", "N/A")
            has_email = "challenge_email" in account_config
            has_sms = "challenge_sms" in account_config

            print(f"\n📱 Compte {i}: {username}")
            print(f"   - Email challenge: {'✅' if has_email else '❌'}")
            print(f"   - SMS challenge: {'✅' if has_sms else '❌'}")

            if has_email:
                email_config = account_config["challenge_email"]
                print(f"   - Email: {email_config.get('email', 'N/A')}")
                print(f"   - Serveur IMAP: {email_config.get('imap_server', 'N/A')}")

        return True

    except Exception as e:
        print(f"❌ Erreur lors du chargement: {e}")
        return False

def main():
    """Fonction principale de démonstration"""
    print("🎭 Démonstration de la gestion des challenges Instagram")
    print("=" * 60)

    # Vérifier les variables d'environnement
    print("🔍 Vérification de la configuration:")
    twocaptcha_key = os.getenv("TWOCAPTCHA_API_KEY")
    challenge_email = os.getenv("CHALLENGE_EMAIL")

    print(f"   - TWOCAPTCHA_API_KEY: {'✅ Configuré' if twocaptcha_key else '❌ Non configuré'}")
    print(f"   - CHALLENGE_EMAIL: {'✅ Configuré' if challenge_email else '❌ Non configuré'}")

    if not twocaptcha_key:
        print("\n💡 Pour activer la résolution automatique de CAPTCHA:")
        print("   export TWOCAPTCHA_API_KEY=\"votre_cle_api\"")

    if not challenge_email:
        print("\n💡 Pour activer la récupération de codes par email:")
        print("   export CHALLENGE_EMAIL=\"votre.email@gmail.com\"")
        print("   export CHALLENGE_EMAIL_PASSWORD=\"votre_mot_de_passe\"")

    # Démonstrations
    demo_challenge_service()

    # Demander si l'utilisateur veut tester avec un vrai compte
    print("\n" + "=" * 60)
    choice = input("Voulez-vous tester avec un vrai compte Instagram? (o/n): ").strip().lower()

    if choice in ['o', 'oui', 'y', 'yes']:
        demo_client_with_challenges()

    # Démonstration du fichier de configuration
    demo_configuration_file()

    print("\n" + "=" * 60)
    print("🎉 Démonstration terminée!")
    print("\n📚 Pour plus d'informations, consultez README_CHALLENGE.md")
    print("🧪 Pour les tests complets, utilisez test_challenge.py")

if __name__ == "__main__":
    main()
