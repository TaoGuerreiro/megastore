# frozen_string_literal: true
"""
Script pour récupérer les followers Instagram
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
    parser = argparse.ArgumentParser(description="Récupérer les followers Instagram")

    # Arguments de configuration (fichier de config en premier argument positionnel)
    parser.add_argument("config_file", help="Fichier de configuration JSON")

    # Arguments spécifiques
    parser.add_argument("target_user", help="Nom d'utilisateur cible")
    parser.add_argument("--limit", type=int, default=100,
                       help="Nombre maximum de followers à récupérer (défaut: 100)")
    parser.add_argument("--cursor", help="Curseur pour la pagination")

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

        # Initialiser le service utilisateur
        user_service = UserService(client, logger)

        # Récupérer les followers
        result = user_service.get_followers(args.target_user, args.limit, args.cursor)

        # Ajouter l'horodatage
        result_with_timestamp = {
            "timestamp": client.get_current_timestamp(),
            "target_user": args.target_user,
            "limit": args.limit,
            "cursor": args.cursor,
            "followers_count": len(result.get("followers", [])),
            "result": result
        }

        # Afficher le résultat
        client.print_json_result(result_with_timestamp)

        # Afficher le résumé des logs sur stderr pour éviter de polluer stdout
        logger.print_summary_to_stderr()

    except Exception as e:
        ErrorHandler.handle_error(str(e))


if __name__ == "__main__":
    main()
