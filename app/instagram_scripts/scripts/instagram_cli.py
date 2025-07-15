# frozen_string_literal: true
"""
Script wrapper unifié pour les scripts Instagram
Simplifie l'utilisation de tous les scripts avec une interface cohérente
"""

import sys
import argparse
import subprocess
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import ConfigLoader, ErrorHandler


def get_available_commands():
    """Obtenir la liste des commandes disponibles"""
    scripts_dir = Path(__file__).parent
    commands = {}

    for script_file in scripts_dir.glob("*.py"):
        if script_file.name.startswith("__") or script_file.name == "instagram_cli.py":
            continue

        command_name = script_file.stem
        commands[command_name] = str(script_file)

    return commands


def run_command(command: str, args: list):
    """Exécuter une commande"""
    try:
        # Construire la commande complète
        cmd = [sys.executable, f"scripts/{command}.py"] + args

        # Exécuter la commande
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=Path(__file__).parent.parent)

        # Afficher la sortie
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)

        return result.returncode

    except Exception as e:
        ErrorHandler.handle_error(f"Erreur lors de l'exécution de la commande {command}: {str(e)}")
        return 1


def show_help():
    """Afficher l'aide détaillée"""
    commands = get_available_commands()

    help_text = """
🚀 Instagram Scripts CLI - Interface unifiée

📋 Commandes disponibles:

"""

    for command, script_path in commands.items():
        help_text += f"  {command:<20} - Script: {script_path}\n"

    help_text += """
📖 Utilisation:
  python scripts/instagram_cli.py <commande> [arguments...]

🔧 Exemples:
  # Recherche de hashtags
  python scripts/instagram_cli.py search_hashtags fashion --config-file config.json --action recent

  # Récupération de followers
  python scripts/instagram_cli.py fetch_followers target_user --config-file config.json --limit 100

  # Like de posts
  python scripts/instagram_cli.py like_posts --mode hashtag --target fashion --config-file config.json

  # Envoi de message
  python scripts/instagram_cli.py send_message 123456789 "Bonjour !" --config-file config.json

  # Création de configuration
  python scripts/instagram_cli.py create_config --type simple --output my_config.json

  # Engagement automatique
  python scripts/instagram_cli.py engagement config.json --campagne-id 123

📝 Arguments communs (pour tous les scripts):
  --config-file, -c    Fichier de configuration JSON
  --env               Utiliser les variables d'environnement
  --username, -u      Nom d'utilisateur Instagram
  --password, -p      Mot de passe Instagram
  --log-dir           Répertoire de logs

🔍 Pour plus d'informations sur une commande spécifique:
  python scripts/instagram_cli.py <commande> --help
"""

    print(help_text)


def main():
    """Fonction principale"""
    parser = argparse.ArgumentParser(
        description="Interface unifiée pour les scripts Instagram",
        add_help=False  # On gère l'aide manuellement
    )

    parser.add_argument("command", nargs="?", help="Commande à exécuter")
    parser.add_argument("args", nargs=argparse.REMAINDER, help="Arguments de la commande")

    args = parser.parse_args()

    # Si pas de commande ou demande d'aide
    if not args.command or args.command in ["-h", "--help", "help"]:
        show_help()
        return 0

    # Vérifier que la commande existe
    commands = get_available_commands()
    if args.command not in commands:
        ErrorHandler.handle_error(
            f"Commande '{args.command}' non reconnue",
            context={
                "available_commands": list(commands.keys()),
                "suggestion": "Utilisez 'python scripts/instagram_cli.py help' pour voir toutes les commandes"
            }
        )

    # Exécuter la commande
    return run_command(args.command, args.args)


if __name__ == "__main__":
    sys.exit(main())
