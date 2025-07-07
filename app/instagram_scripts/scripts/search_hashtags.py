# frozen_string_literal: true
"""
Script pour la recherche de hashtags Instagram
"""

import sys
import argparse
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core.client import InstagramClient
from core.logger import InstagramLogger
from services.hashtag_service import HashtagService


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Rechercher des informations sur un hashtag Instagram")
    parser.add_argument("username", help="Nom d'utilisateur Instagram")
    parser.add_argument("password", help="Mot de passe Instagram")
    parser.add_argument("hashtag_name", help="Nom du hashtag (sans #)")
    parser.add_argument("--action", default="info",
                       choices=["info", "recent", "top", "recent_a1", "top_a1", "related"],
                       help="Type d'action (défaut: info)")
    parser.add_argument("--amount", type=int, default=20,
                       help="Nombre de posts à récupérer (défaut: 20)")
    parser.add_argument("--cursor", help="Curseur pour la pagination")
    parser.add_argument("--log-dir", default="logs",
                       help="Répertoire de logs (défaut: logs)")

    args = parser.parse_args()

    try:
        # Initialiser le client et le logger
        client = InstagramClient(args.username, args.password)
        logger = InstagramLogger(args.username, args.log_dir)

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

        # Afficher le résumé des logs
        logger.print_summary()

    except Exception as e:
        print(f'{{"error": "{str(e)}"}}')
        sys.exit(1)


if __name__ == "__main__":
    main()
