# frozen_string_literal: true
"""
Script pour envoyer un message Instagram
"""

import sys
import argparse
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import InstagramClient, InstagramLogger, ConfigLoader, ErrorHandler
from services.message_service import MessageService


def main():
    """Fonction principale du script"""
    parser = argparse.ArgumentParser(description="Envoyer un message Instagram")

    # Arguments de configuration (fichier de config en premier argument positionnel)
    parser.add_argument("config_file", help="Fichier de configuration JSON")

    # Arguments spécifiques au message
    parser.add_argument("recipient_id", help="ID de l'utilisateur destinataire")
    parser.add_argument("message", help="Contenu du message")

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

        # Initialiser le service message
        message_service = MessageService(client, logger)

        # Envoyer le message
        result = message_service.send_message(args.recipient_id, args.message)

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
