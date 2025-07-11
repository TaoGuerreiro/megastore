# frozen_string_literal: true
"""
Script pour récupérer les messages Instagram
"""

import sys
import argparse
import json
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core.client import InstagramClient
from core.logger import InstagramLogger
from services.message_service import MessageService


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Récupérer les messages Instagram")
    parser.add_argument("config_file", help="Fichier de configuration JSON")
    parser.add_argument("recipient_id", help="ID de l'utilisateur destinataire")
    parser.add_argument("--hours-back", type=float, default=24,
                       help="Nombre d'heures en arrière pour filtrer (défaut: 24)")
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
