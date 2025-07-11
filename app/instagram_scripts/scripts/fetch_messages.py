# frozen_string_literal: true
"""
Script pour récupérer les messages Instagram
"""

import sys
import argparse
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core.client import InstagramClient
from core.logger import InstagramLogger
from services.message_service import MessageService


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Récupérer les messages Instagram")
    parser.add_argument("username", help="Nom d'utilisateur Instagram")
    parser.add_argument("password", help="Mot de passe Instagram")
    parser.add_argument("recipient_id", help="ID de l'utilisateur destinataire")
    parser.add_argument("--hours-back", type=float, default=24,
                       help="Nombre d'heures en arrière pour filtrer (défaut: 24)")
    parser.add_argument("--log-dir", default="logs",
                       help="Répertoire de logs (défaut: logs)")

    args = parser.parse_args()

    try:
        # Initialiser le client et le logger
        client = InstagramClient(args.username, args.password)
        logger = InstagramLogger(args.username, args.log_dir)

        # Initialiser le service message
        message_service = MessageService(client, logger)

        # Récupérer les messages
        result = message_service.get_messages(args.recipient_id, args.hours_back)

        # Ajouter l'horodatage
        result_with_timestamp = {
            "timestamp": client.get_current_timestamp(),
            "recipient_id": args.recipient_id,
            "hours_back": args.hours_back,
            "messages_count": len(result),
            "messages": result
        }

        # Afficher le résultat
        client.print_json_result(result_with_timestamp)

        # Afficher le résumé des logs sur stderr pour éviter de polluer stdout
        logger.print_summary_to_stderr()

    except Exception as e:
        print(f'{{"error": "{str(e)}"}}')
        sys.exit(1)


if __name__ == "__main__":
    main()
