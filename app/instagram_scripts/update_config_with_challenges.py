#!/usr/bin/env python3
# frozen_string_literal: true
"""
Script pour ajouter la configuration de challenge aux fichiers de configuration existants
"""

import os
import sys
import json
import argparse
from datetime import datetime

def add_challenge_config_to_file(config_file_path, challenge_config=None):
    """
    Ajouter la configuration de challenge à un fichier de configuration existant

    Args:
        config_file_path: Chemin vers le fichier de configuration
        challenge_config: Configuration de challenge à ajouter
    """
    try:
        # Lire la configuration existante
        with open(config_file_path, 'r', encoding='utf-8') as f:
            config = json.load(f)

        # Configuration de challenge par défaut
        default_challenge_config = {
            "challenge_email": {
                "email": os.getenv("CHALLENGE_EMAIL", "votre.email@gmail.com"),
                "password": os.getenv("CHALLENGE_EMAIL_PASSWORD", "votre_mot_de_passe_email"),
                "imap_server": "imap.gmail.com"
            },
            "challenge_sms": {
                "provider": "twilio",
                "account_sid": os.getenv("TWILIO_ACCOUNT_SID", "votre_account_sid"),
                "auth_token": os.getenv("TWILIO_AUTH_TOKEN", "votre_auth_token"),
                "phone_number": os.getenv("CHALLENGE_PHONE", "+33123456789")
            }
        }

        # Utiliser la configuration fournie ou la configuration par défaut
        challenge_config = challenge_config or default_challenge_config

        # Ajouter la configuration de challenge à chaque compte
        updated = False
        for account in config:
            if isinstance(account, dict) and "username" in account:
                # Vérifier si la configuration de challenge existe déjà
                if "challenge_email" not in account:
                    account["challenge_email"] = challenge_config["challenge_email"]
                    updated = True
                    print(f"   ✅ Email challenge ajouté pour {account['username']}")

                if "challenge_sms" not in account:
                    account["challenge_sms"] = challenge_config["challenge_sms"]
                    updated = True
                    print(f"   ✅ SMS challenge ajouté pour {account['username']}")

        if updated:
            # Sauvegarder la configuration mise à jour
            backup_path = f"{config_file_path}.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            with open(backup_path, 'w', encoding='utf-8') as f:
                json.dump(config, f, ensure_ascii=False, indent=2)
            print(f"   💾 Sauvegarde créée: {backup_path}")

            with open(config_file_path, 'w', encoding='utf-8') as f:
                json.dump(config, f, ensure_ascii=False, indent=2)
            print(f"   ✅ Configuration mise à jour: {config_file_path}")
        else:
            print(f"   ℹ️  Configuration déjà présente dans {config_file_path}")

        return True

    except Exception as e:
        print(f"   ❌ Erreur lors de la mise à jour de {config_file_path}: {e}")
        return False

def create_challenge_config_template():
    """Créer un template de configuration de challenge"""
    template = {
        "challenge_email": {
            "email": "votre.email@gmail.com",
            "password": "votre_mot_de_passe_email",
            "imap_server": "imap.gmail.com"
        },
        "challenge_sms": {
            "provider": "twilio",
            "account_sid": "votre_account_sid",
            "auth_token": "votre_auth_token",
            "phone_number": "+33123456789"
        }
    }

    template_path = "challenge_config_template.json"
    with open(template_path, 'w', encoding='utf-8') as f:
        json.dump(template, f, ensure_ascii=False, indent=2)

    print(f"✅ Template créé: {template_path}")
    return template

def main():
    parser = argparse.ArgumentParser(description="Ajouter la configuration de challenge aux fichiers de configuration")
    parser.add_argument("--config-file", help="Fichier de configuration à mettre à jour")
    parser.add_argument("--template", action="store_true", help="Créer un template de configuration de challenge")
    parser.add_argument("--all", action="store_true", help="Mettre à jour tous les fichiers .json dans le répertoire")
    parser.add_argument("--challenge-config", help="Fichier de configuration de challenge personnalisé")

    args = parser.parse_args()

    print("🔧 Mise à jour des configurations avec gestion des challenges")
    print("=" * 60)

    # Charger la configuration de challenge personnalisée si fournie
    challenge_config = None
    if args.challenge_config:
        try:
            with open(args.challenge_config, 'r', encoding='utf-8') as f:
                challenge_config = json.load(f)
            print(f"✅ Configuration de challenge chargée: {args.challenge_config}")
        except Exception as e:
            print(f"❌ Erreur lors du chargement de {args.challenge_config}: {e}")
            return

    # Créer un template
    if args.template:
        create_challenge_config_template()
        return

    # Mettre à jour un fichier spécifique
    if args.config_file:
        print(f"📁 Mise à jour de {args.config_file}")
        if add_challenge_config_to_file(args.config_file, challenge_config):
            print("✅ Mise à jour terminée")
        else:
            print("❌ Échec de la mise à jour")
        return

    # Mettre à jour tous les fichiers
    if args.all:
        print("📁 Recherche de fichiers de configuration...")
        config_files = []

        # Chercher les fichiers .json dans le répertoire courant
        for file in os.listdir("."):
            if file.endswith(".json") and file != "challenge_config_template.json":
                config_files.append(file)

        if not config_files:
            print("❌ Aucun fichier de configuration trouvé")
            return

        print(f"📋 Fichiers trouvés: {len(config_files)}")
        for config_file in config_files:
            print(f"\n📁 Traitement de {config_file}")
            add_challenge_config_to_file(config_file, challenge_config)

        print("\n✅ Mise à jour terminée pour tous les fichiers")
        return

    # Mode interactif
    print("🔍 Mode interactif")
    print("\nOptions disponibles:")
    print("1. Créer un template de configuration de challenge")
    print("2. Mettre à jour un fichier spécifique")
    print("3. Mettre à jour tous les fichiers .json")
    print("4. Quitter")

    choice = input("\nVotre choix (1-4): ").strip()

    if choice == "1":
        create_challenge_config_template()
    elif choice == "2":
        config_file = input("Chemin vers le fichier de configuration: ").strip()
        if config_file:
            add_challenge_config_to_file(config_file, challenge_config)
    elif choice == "3":
        print("📁 Recherche de fichiers de configuration...")
        config_files = [f for f in os.listdir(".") if f.endswith(".json") and f != "challenge_config_template.json"]
        for config_file in config_files:
            print(f"\n📁 Traitement de {config_file}")
            add_challenge_config_to_file(config_file, challenge_config)
    elif choice == "4":
        print("👋 Au revoir!")
    else:
        print("❌ Choix invalide")

if __name__ == "__main__":
    main()
