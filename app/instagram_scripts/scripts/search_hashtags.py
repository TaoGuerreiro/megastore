# frozen_string_literal: true
"""
Script pour la recherche de hashtags Instagram
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
    parser = argparse.ArgumentParser(description="Rechercher des informations sur un hashtag Instagram")

    # Arguments spécifiques au hashtag
    parser.add_argument("hashtag_name", help="Nom du hashtag (sans #)")
    parser.add_argument("--action", default="info",
                       choices=["info", "recent", "top", "recent_a1", "top_a1", "related"],
                       help="Type d'action (défaut: info)")
    parser.add_argument("--amount", type=int, default=20,
                       help="Nombre de posts à récupérer (défaut: 20)")
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

        # Initialiser le service hashtag
        hashtag_service = HashtagService(client, logger)

        # Exécuter l'action demandée
        if args.action == "info":
            result = hashtag_service.get_hashtag_info(args.hashtag_name)
        elif args.action == "related":
            result = hashtag_service.get_related_hashtags(args.hashtag_name)
        else:
            result = hashtag_service.get_hashtag_posts(
                args.hashtag_name,
                args.action,
                args.amount,
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
