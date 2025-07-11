# frozen_string_literal: true
"""
Script pour récupérer l'ID d'un utilisateur Instagram
"""

import sys
import argparse
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import InstagramClient, InstagramLogger, ConfigLoader, ErrorHandler


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Récupérer l'ID d'un utilisateur Instagram")

    # Arguments de configuration (fichier de config en premier argument positionnel)
    parser.add_argument("config_file", help="Fichier de configuration JSON")

    # Arguments spécifiques
    parser.add_argument("handle", help="Nom d'utilisateur cible")

    # Arguments optionnels
    parser.add_argument(
        "--log-dir",
        default="logs",
        help="Répertoire de logs (défaut: logs)"
    )

    args = parser.parse_args()

    try:
        # Charger la configuration depuis le fichier
        config = ConfigLoader.load_from_file(args.config_file)
        ConfigLoader.validate_config(config)

        # Extraire les paramètres
        username = config["username"]
        password = config["password"]
        challenge_config = ConfigLoader.get_challenge_config(config)

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
        ErrorHandler.handle_error(str(e))


if __name__ == "__main__":
    main()
