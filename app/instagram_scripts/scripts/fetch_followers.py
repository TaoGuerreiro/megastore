# frozen_string_literal: true
"""
Script pour récupérer les followers d'un utilisateur Instagram
"""

import sys
import argparse
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import InstagramClient, InstagramLogger, ConfigLoader, ErrorHandler
from services.user_service import UserService


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Récupérer les followers d'un utilisateur Instagram")

    # Arguments spécifiques aux followers
    parser.add_argument("target_username", help="Nom d'utilisateur cible")
    parser.add_argument("--limit", type=int, help="Nombre de followers à récupérer")
    parser.add_argument("--offset", type=int, default=0, help="Offset pour la pagination (défaut: 0)")
    parser.add_argument("--cursor", help="Curseur pour la pagination")

    # Arguments de configuration unifiés
    ConfigLoader.add_common_args(parser)

    args = parser.parse_args()

    try:
        # Charger la configuration
        config = ConfigLoader.load_config_from_args(args)
        ConfigLoader.validate_config(config)

        # Extraire les paramètres
        username = config["username"]
        password = config["password"]
        challenge_config = ConfigLoader.get_challenge_config(config)

        # Initialiser le client et le logger
        client = InstagramClient(username, password, challenge_config=challenge_config)
        logger = InstagramLogger(username, args.log_dir)

        # Initialiser le service utilisateur
        user_service = UserService(client, logger)

        # Récupérer les followers
        result = user_service.get_user_followers(
            args.target_username,
            args.limit,
            args.offset,
            args.cursor
        )

        # Ajouter l'horodatage
        result["timestamp"] = client.get_current_timestamp()

        # Afficher le résultat
        client.print_json_result(result)

        # Afficher le résumé des logs sur stderr pour éviter de polluer stdout
        logger.print_summary_to_stderr()

    except Exception as e:
        ErrorHandler.handle_error(str(e))


if __name__ == "__main__":
    main()
