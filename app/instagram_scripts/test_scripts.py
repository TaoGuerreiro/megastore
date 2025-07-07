# frozen_string_literal: true
"""
Script de test pour valider la nouvelle architecture des scripts Instagram
"""

import sys
import argparse
import subprocess
from pathlib import Path


def test_imports():
    """Tester les imports des modules"""
    print("🔍 Test des imports...")

    try:
        from core.client import InstagramClient
        from core.logger import InstagramLogger
        from services.hashtag_service import HashtagService
        from services.user_service import UserService
        from services.message_service import MessageService
        from config import InstagramConfig
        print("✅ Tous les imports réussis")
        return True
    except ImportError as e:
        print(f"❌ Erreur d'import: {e}")
        return False


def test_config():
    """Tester la configuration"""
    print("🔍 Test de la configuration...")

    try:
        from config import InstagramConfig

        # Test des méthodes de configuration
        rate_limits = InstagramConfig.get_rate_limits()
        delays = InstagramConfig.get_delays()
        limits = InstagramConfig.get_limits()

        assert isinstance(rate_limits, dict)
        assert isinstance(delays, dict)
        assert isinstance(limits, dict)

        print("✅ Configuration valide")
        return True
    except Exception as e:
        print(f"❌ Erreur de configuration: {e}")
        return False


def test_script_help():
    """Tester l'aide des scripts"""
    print("🔍 Test de l'aide des scripts...")

    scripts = [
        "scripts/search_hashtags.py",
        "scripts/fetch_followers.py",
        "scripts/fetch_messages.py",
        "scripts/send_message.py",
        "scripts/like_posts.py",
        "scripts/fetch_user_id.py"
    ]

    success_count = 0

    for script in scripts:
        if Path(script).exists():
            try:
                result = subprocess.run(
                    [sys.executable, script, "--help"],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                if result.returncode == 0:
                    print(f"✅ {script}: OK")
                    success_count += 1
                else:
                    print(f"❌ {script}: Erreur")
            except Exception as e:
                print(f"❌ {script}: {e}")
        else:
            print(f"⚠️ {script}: Fichier manquant")

    return success_count == len(scripts)


def test_directory_structure():
    """Tester la structure des répertoires"""
    print("🔍 Test de la structure des répertoires...")

    required_dirs = ["core", "services", "scripts"]
    required_files = [
        "core/__init__.py",
        "core/client.py",
        "core/logger.py",
        "services/__init__.py",
        "services/hashtag_service.py",
        "services/user_service.py",
        "services/message_service.py",
        "scripts/__init__.py",
        "scripts/search_hashtags.py",
        "scripts/fetch_followers.py",
        "scripts/fetch_messages.py",
        "scripts/send_message.py",
        "scripts/like_posts.py",
        "scripts/fetch_user_id.py",
        "config.py",
        "README.md"
    ]

    # Vérifier les répertoires
    for dir_name in required_dirs:
        if Path(dir_name).exists():
            print(f"✅ Répertoire {dir_name}: OK")
        else:
            print(f"❌ Répertoire {dir_name}: Manquant")
            return False

    # Vérifier les fichiers
    missing_files = []
    for file_path in required_files:
        if Path(file_path).exists():
            print(f"✅ Fichier {file_path}: OK")
        else:
            print(f"❌ Fichier {file_path}: Manquant")
            missing_files.append(file_path)

    if missing_files:
        print(f"⚠️ Fichiers manquants: {missing_files}")
        return False

    return True


def test_migration_script():
    """Tester le script de migration"""
    print("🔍 Test du script de migration...")

    if Path("migrate.py").exists():
        try:
            result = subprocess.run(
                [sys.executable, "migrate.py", "--guide"],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                print("✅ Script de migration: OK")
                return True
            else:
                print(f"❌ Script de migration: Erreur")
                return False
        except Exception as e:
            print(f"❌ Script de migration: {e}")
            return False
    else:
        print("⚠️ Script de migration: Fichier manquant")
        return False


def run_all_tests():
    """Exécuter tous les tests"""
    print("🚀 Démarrage des tests de la nouvelle architecture...\n")

    tests = [
        ("Structure des répertoires", test_directory_structure),
        ("Configuration", test_config),
        ("Imports des modules", test_imports),
        ("Aide des scripts", test_script_help),
        ("Script de migration", test_migration_script)
    ]

    results = []

    for test_name, test_func in tests:
        print(f"\n📋 {test_name}")
        print("-" * 50)
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ Erreur lors du test: {e}")
            results.append((test_name, False))

    # Résumé
    print("\n" + "=" * 60)
    print("📊 RÉSUMÉ DES TESTS")
    print("=" * 60)

    passed = 0
    total = len(results)

    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {test_name}")
        if result:
            passed += 1

    print(f"\n🎯 Résultat: {passed}/{total} tests réussis")

    if passed == total:
        print("🎉 Tous les tests sont passés ! La nouvelle architecture est prête.")
        return True
    else:
        print("⚠️ Certains tests ont échoué. Vérifiez les erreurs ci-dessus.")
        return False


def main():
    """Fonction principale"""
    parser = argparse.ArgumentParser(description="Tests de la nouvelle architecture Instagram")
    parser.add_argument("--test", choices=["imports", "config", "scripts", "structure", "migration", "all"],
                       default="all", help="Type de test à exécuter")

    args = parser.parse_args()

    if args.test == "all":
        success = run_all_tests()
        sys.exit(0 if success else 1)
    elif args.test == "imports":
        success = test_imports()
    elif args.test == "config":
        success = test_config()
    elif args.test == "scripts":
        success = test_script_help()
    elif args.test == "structure":
        success = test_directory_structure()
    elif args.test == "migration":
        success = test_migration_script()

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
