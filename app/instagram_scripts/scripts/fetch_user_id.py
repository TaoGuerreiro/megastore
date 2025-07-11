# frozen_string_literal: true
"""
Script pour récupérer l'ID d'un utilisateur Instagram
"""

import sys
import argparse
import json
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core.client import InstagramClient
from core.logger import InstagramLogger


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Récupérer l'ID d'un utilisateur Instagram")
    parser.add_argument("config_file", help="Fichier de configuration JSON")
    parser.add_argument("handle", help="Nom d'utilisateur cible")
    parser.add_argument("--log-dir", default="logs",
                       help="Répertoire de logs (défaut: logs)")

    args = parser.parse_args()

    try:
        # Charger la configuration
        with open(args.config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)

        username = config.get("username")
        password = config.get("password")
        challenge_config = config.get("challenge_config", {})

        if not username or not password:
            raise ValueError("Username et password requis dans le fichier de configuration")

        # Initialiser le client et le logger
        client = InstagramClient(username, password, challenge_config=challenge_config)
        logger = InstagramLogger(username, args.log_dir)

        # Récupérer l'ID utilisateur
        user_id = client.get_user_id_from_username(args.handle)

        result = {
            "handle": args.handle,
            "user_id": str(user_id),
            "timestamp": client.get_current_timestamp()
        }

        # Logger l'action
        logger.log_action("fetch_user_id", {
            "handle": args.handle,
            "user_id": str(user_id)
        })

        # Afficher le résultat
        client.print_json_result(result)

        # Afficher le résumé des logs sur stderr pour éviter de polluer stdout
        logger.print_summary_to_stderr()

    except Exception as e:
        print(f'{{"error": "{str(e)}"}}')
        sys.exit(1)


if __name__ == "__main__":
    main()
