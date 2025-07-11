# frozen_string_literal: true
"""
Script pour créer des templates de configuration
"""

import sys
import argparse
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import ConfigLoader, ErrorHandler


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Créer des templates de configuration")
    parser.add_argument("--output", "-o", default="config_template.json",
                       help="Fichier de sortie pour le template (défaut: config_template.json)")
    parser.add_argument("--type", "-t", choices=["simple", "engagement", "full"],
                       default="full", help="Type de template (défaut: full)")
    parser.add_argument("--force", "-f", action="store_true",
                       help="Écraser le fichier s'il existe déjà")

    args = parser.parse_args()

    try:
        output_path = Path(args.output)

        # Vérifier si le fichier existe
        if output_path.exists() and not args.force:
            ErrorHandler.handle_error(f"Le fichier {args.output} existe déjà. Utilisez --force pour l'écraser.")

        # Créer le template selon le type
        if args.type == "simple":
            template = {
                "username": "votre_username_instagram",
                "password": "votre_mot_de_passe_instagram",
                "challenge_config": {
                    "two_captcha_api_key": "votre_cle_2captcha",
                    "challenge_email": {
                        "email": "votre_email@gmail.com",
                        "password": "mot_de_passe_email",
                        "imap_server": "imap.gmail.com"
                    }
                }
            }
        elif args.type == "engagement":
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
                    }
                }
            }
        else:  # full
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

        # Créer le template
        ConfigLoader.create_template_config(str(output_path))

        print(f"✅ Template de configuration créé: {output_path}")
        print(f"📝 Type: {args.type}")
        print(f"🔧 Modifiez le fichier avec vos informations avant utilisation")

    except Exception as e:
        ErrorHandler.handle_error(str(e))


if __name__ == "__main__":
    main()
