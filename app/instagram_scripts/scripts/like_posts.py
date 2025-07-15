# frozen_string_literal: true
"""
Script pour liker des posts Instagram
"""

import sys
import argparse
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import InstagramClient, InstagramLogger, ConfigLoader, ErrorHandler
from services.hashtag_service import HashtagService
from services.user_service import UserService


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Liker des posts Instagram")

    # Arguments de configuration (fichier de config en premier argument positionnel)
    parser.add_argument("config_file", help="Fichier de configuration JSON")

    # Arguments spécifiques
    parser.add_argument("--hashtag", help="Hashtag pour liker des posts")
    parser.add_argument("--user", help="Nom d'utilisateur pour liker ses posts")
    parser.add_argument("--amount", type=int, default=10,
                       help="Nombre de posts à liker (défaut: 10)")
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

        # Initialiser les services
        hashtag_service = HashtagService(client, logger)
        user_service = UserService(client, logger)

        # Déterminer l'action à effectuer
        if args.hashtag:
            # Liker des posts d'un hashtag
            result = hashtag_service.like_hashtag_posts(args.hashtag, args.amount, args.cursor)
            action_type = "hashtag"
            target = args.hashtag
        elif args.user:
            # Liker des posts d'un utilisateur
            result = user_service.like_user_posts(args.user, args.amount, args.cursor)
            action_type = "user"
            target = args.user
        else:
            raise ValueError("Vous devez spécifier --hashtag ou --user")

        # Ajouter l'horodatage
        result_with_timestamp = {
            "timestamp": client.get_current_timestamp(),
            "action_type": action_type,
            "target": target,
            "amount": args.amount,
            "cursor": args.cursor,
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
