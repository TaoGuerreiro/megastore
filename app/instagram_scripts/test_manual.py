#!/usr/bin/env python3
# frozen_string_literal: true
"""
Script de test manuel pour les scripts Instagram
Permet de tester les scripts de manière interactive
"""

import sys
import json
import tempfile
import os
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent))

from core import ConfigLoader, ErrorHandler


def test_script_interactive(script_name, *args):
    """Tester un script de manière interactive"""
    print(f"\n🧪 Test de {script_name}")
    print("=" * 50)

    # Demander les credentials
    username = input("Username Instagram (ou 'test' pour utiliser des données de test): ").strip()
    password = input("Password Instagram (ou 'test' pour utiliser des données de test): ").strip()

    if username == "test" or password == "test":
        username = "test_user"
        password = "test_password"
        print("⚠️  Utilisation de données de test")

    # Créer le fichier de config
    config = {
        "username": username,
        "password": password,
        "challenge_config": {
            "two_captcha_api_key": "test_key",
            "challenge_email": {
                "email": "test@example.com",
                "password": "test_password",
                "imap_server": "imap.gmail.com"
            }
        }
    }

    config_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
    config_file.write(json.dumps(config, indent=2))
    config_file.close()

    try:
        # Construire la commande
        script_path = Path(__file__).parent / "scripts" / script_name
        python_executable = "python3" if os.name != "nt" else "python"

        cmd = [python_executable, str(script_path), config_file.name] + list(args)

        print(f"🚀 Exécution: {' '.join(cmd)}")
        print("-" * 50)

        # Exécuter le script
        import subprocess
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)

        print("📤 Sortie standard:")
        print(result.stdout)

        if result.stderr:
            print("⚠️  Erreurs:")
            print(result.stderr)

        print(f"📊 Code de retour: {result.returncode}")

        if result.returncode == 0:
            print("✅ Script exécuté avec succès")
        else:
            print("❌ Script a échoué")

    except subprocess.TimeoutExpired:
        print("⏰ Timeout - le script a pris trop de temps")
    except Exception as e:
        print(f"❌ Erreur: {e}")
    finally:
        # Nettoyer
        os.unlink(config_file.name)


def test_fetch_user_id():
    """Test de fetch_user_id.py"""
    handle = input("Handle à tester (défaut: instagram): ").strip() or "instagram"
    test_script_interactive("fetch_user_id.py", handle)


def test_search_hashtags():
    """Test de search_hashtags.py"""
    query = input("Requête de recherche (défaut: fashion): ").strip() or "fashion"
    limit = input("Limite (défaut: 5): ").strip() or "5"
    test_script_interactive("search_hashtags.py", query, "--limit", limit)


def test_send_message():
    """Test de send_message.py"""
    recipient_id = input("ID du destinataire (défaut: 999999999 pour test): ").strip() or "999999999"
    message = input("Message (défaut: Test message): ").strip() or "Test message"
    test_script_interactive("send_message.py", recipient_id, message)


def test_fetch_messages():
    """Test de fetch_messages.py"""
    recipient_id = input("ID du destinataire (défaut: 999999999 pour test): ").strip() or "999999999"
    hours_back = input("Heures en arrière (défaut: 24): ").strip() or "24"
    test_script_interactive("fetch_messages.py", recipient_id, "--hours-back", hours_back)


def test_fetch_followers():
    """Test de fetch_followers.py"""
    target_user = input("Utilisateur cible (défaut: instagram): ").strip() or "instagram"
    limit = input("Limite (défaut: 10): ").strip() or "10"
    test_script_interactive("fetch_followers.py", target_user, "--limit", limit)


def test_like_posts():
    """Test de like_posts.py"""
    print("Mode de test:")
    print("1. Hashtag")
    print("2. Utilisateur")
    choice = input("Choix (1-2, défaut: 1): ").strip() or "1"

    if choice == "1":
        hashtag = input("Hashtag (défaut: fashion): ").strip() or "fashion"
        amount = input("Nombre de posts (défaut: 2): ").strip() or "2"
        test_script_interactive("like_posts.py", "--hashtag", hashtag, "--amount", amount)
    else:
        user = input("Utilisateur (défaut: instagram): ").strip() or "instagram"
        amount = input("Nombre de posts (défaut: 2): ").strip() or "2"
        test_script_interactive("like_posts.py", "--user", user, "--amount", amount)


def test_engagement():
    """Test de engagement.py"""
    print("⚠️  Test d'engagement - attention aux limites Instagram!")
    confirm = input("Continuer? (y/N): ").strip().lower()

    if confirm == "y":
        # Créer une config d'engagement simple
        config = {
            "username": "test_user",
            "password": "test_password",
            "hashtags": [{"hashtag": "fashion"}],
            "targeted_accounts": [{"account": "instagram"}],
            "challenge_config": {}
        }

        config_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        config_file.write(json.dumps([config], indent=2))
        config_file.close()

        try:
            script_path = Path(__file__).parent / "scripts" / "engagement.py"
            python_executable = "python3" if os.name != "nt" else "python"

            cmd = [python_executable, str(script_path), config_file.name]

            print(f"🚀 Exécution: {' '.join(cmd)}")

            import subprocess
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)

            print("📤 Sortie standard:")
            print(result.stdout)

            if result.stderr:
                print("⚠️  Erreurs:")
                print(result.stderr)

        except Exception as e:
            print(f"❌ Erreur: {e}")
        finally:
            os.unlink(config_file.name)
    else:
        print("❌ Test annulé")


def check_environment():
    """Vérifier l'environnement"""
    print("🔍 Vérification de l'environnement...")

    # Vérifier Python
    python_version = sys.version
    print(f"✅ Python: {python_version}")

    # Vérifier les modules requis
    required_modules = [
        'instagrapi',
        'requests',
        'json',
        'argparse',
        'pathlib'
    ]

    missing_modules = []
    for module in required_modules:
        try:
            __import__(module)
            print(f"✅ {module}")
        except ImportError:
            print(f"❌ {module} manquant")
            missing_modules.append(module)

    # Vérifier les scripts
    scripts_dir = Path(__file__).parent / "scripts"
    required_scripts = [
        "fetch_user_id.py",
        "search_hashtags.py",
        "send_message.py",
        "fetch_messages.py",
        "fetch_followers.py",
        "like_posts.py",
        "engagement.py"
    ]

    print("\n📁 Scripts:")
    for script in required_scripts:
        script_path = scripts_dir / script
        if script_path.exists():
            print(f"✅ {script}")
        else:
            print(f"❌ {script} manquant")

    if missing_modules:
        print(f"\n⚠️  Modules manquants: {', '.join(missing_modules)}")
        print("Installez-les avec: pip install " + " ".join(missing_modules))


def main():
    """Menu principal"""
    print("🧪 Test Manuel des Scripts Instagram")
    print("=" * 50)

    while True:
        print("\n📋 Menu:")
        print("1. Vérifier l'environnement")
        print("2. Test fetch_user_id.py")
        print("3. Test search_hashtags.py")
        print("4. Test send_message.py")
        print("5. Test fetch_messages.py")
        print("6. Test fetch_followers.py")
        print("7. Test like_posts.py")
        print("8. Test engagement.py")
        print("9. Quitter")

        choice = input("\nChoix (1-9): ").strip()

        if choice == "1":
            check_environment()
        elif choice == "2":
            test_fetch_user_id()
        elif choice == "3":
            test_search_hashtags()
        elif choice == "4":
            test_send_message()
        elif choice == "5":
            test_fetch_messages()
        elif choice == "6":
            test_fetch_followers()
        elif choice == "7":
            test_like_posts()
        elif choice == "8":
            test_engagement()
        elif choice == "9":
            print("👋 Au revoir!")
            break
        else:
            print("❌ Choix invalide")


if __name__ == "__main__":
    main()
