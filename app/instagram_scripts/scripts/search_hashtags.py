# frozen_string_literal: true
"""
Script pour rechercher des hashtags Instagram
"""

import sys
import argparse
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import InstagramClient, InstagramLogger, ConfigLoader, ErrorHandler
from services.hashtag_service import HashtagService


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Rechercher des hashtags Instagram")

    # Arguments de configuration (fichier de config en premier argument positionnel)
    parser.add_argument("config_file", help="Fichier de configuration JSON")

    # Arguments spécifiques aux hashtags
    parser.add_argument("query", help="Requête de recherche de hashtag")
    parser.add_argument("--limit", type=int, default=20,
                       help="Nombre maximum de résultats (défaut: 20)")

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

        # Initialiser le service hashtag
        hashtag_service = HashtagService(client, logger)

        # Rechercher les hashtags
        result = hashtag_service.search_hashtags(args.query, args.limit)

        # Ajouter l'horodatage
        result_with_timestamp = {
            "timestamp": client.get_current_timestamp(),
            "query": args.query,
            "limit": args.limit,
            "hashtags_count": len(result),
            "hashtags": result
        }

        # Afficher le résultat
        client.print_json_result(result_with_timestamp)

        # Afficher le résumé des logs sur stderr pour éviter de polluer stdout
        logger.print_summary_to_stderr()

    except Exception as e:
        ErrorHandler.handle_error(str(e))


if __name__ == "__main__":
    main()
