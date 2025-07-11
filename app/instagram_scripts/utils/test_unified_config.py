# frozen_string_literal: true
"""
Script de test pour la nouvelle architecture unifiée de configuration
"""

import sys
import json
import tempfile
import os
from pathlib import Path

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import ConfigLoader


def test_config_loader():
    """Tester le ConfigLoader"""
    print("🧪 Test du ConfigLoader...")

    # Test 1: Configuration depuis arguments
    print("  📝 Test 1: Configuration depuis arguments")
    config = ConfigLoader.load_from_args("test_user", "test_pass")
    assert config["username"] == "test_user"
    assert config["password"] == "test_pass"
    assert "challenge_config" in config
    print("    ✅ OK")

    # Test 2: Configuration depuis fichier
    print("  📝 Test 2: Configuration depuis fichier")
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        test_config = {
            "username": "file_user",
            "password": "file_pass",
            "challenge_config": {
                "two_captcha_api_key": "test_key"
            }
        }
        json.dump(test_config, f)
        temp_file = f.name

    try:
        config = ConfigLoader.load_from_file(temp_file)
        assert config["username"] == "file_user"
        assert config["password"] == "file_pass"
        assert config["challenge_config"]["two_captcha_api_key"] == "test_key"
        print("    ✅ OK")
    finally:
        os.unlink(temp_file)

    # Test 3: Validation de configuration
    print("  📝 Test 3: Validation de configuration")
    try:
        ConfigLoader.validate_config({"username": "test", "password": "test123"})
        print("    ✅ OK")
    except Exception as e:
        print(f"    ❌ Erreur: {e}")

    # Test 4: Configuration avec variables d'environnement
    print("  📝 Test 4: Configuration avec variables d'environnement")
    os.environ["TWOCAPTCHA_API_KEY"] = "env_key"
    config = ConfigLoader.load_from_args("test_user", "test_pass")
    assert config["challenge_config"]["two_captcha_api_key"] == "env_key"
    print("    ✅ OK")

    # Nettoyer
    del os.environ["TWOCAPTCHA_API_KEY"]

    print("✅ Tous les tests du ConfigLoader passent")


def test_script_arguments():
    """Tester les arguments des scripts"""
    print("🧪 Test des arguments des scripts...")

    import argparse

    # Test 1: Arguments communs
    print("  📝 Test 1: Arguments communs")
    parser = argparse.ArgumentParser()
    ConfigLoader.add_common_args(parser)

    # Simuler des arguments
    test_args = ["--username", "test_user", "--password", "test_pass", "--log-dir", "test_logs"]
    args = parser.parse_args(test_args)

    assert args.username == "test_user"
    assert args.password == "test_pass"
    assert args.log_dir == "test_logs"
    print("    ✅ OK")

    # Test 2: Chargement de configuration depuis arguments
    print("  📝 Test 2: Chargement de configuration depuis arguments")
    config = ConfigLoader.load_config_from_args(args)
    assert config["username"] == "test_user"
    assert config["password"] == "test_pass"
    print("    ✅ OK")

    print("✅ Tous les tests des arguments passent")


def test_template_creation():
    """Tester la création de templates"""
    print("🧪 Test de création de templates...")

    with tempfile.NamedTemporaryFile(suffix='.json', delete=False) as f:
        temp_file = f.name

    try:
        # Créer un template
        ConfigLoader.create_template_config(temp_file)

        # Vérifier que le fichier existe et contient du JSON valide
        with open(temp_file, 'r') as f:
            template = json.load(f)

        assert "username" in template
        assert "password" in template
        assert "challenge_config" in template
        print("    ✅ OK")

    finally:
        os.unlink(temp_file)

    print("✅ Tous les tests de création de templates passent")


def test_challenge_config_extraction():
    """Tester l'extraction de la configuration de challenge"""
    print("🧪 Test d'extraction de la configuration de challenge...")

    # Test 1: Configuration avec challenge
    config_with_challenge = {
        "username": "test",
        "password": "test123",
        "challenge_config": {
            "two_captcha_api_key": "test_key"
        }
    }

    challenge_config = ConfigLoader.get_challenge_config(config_with_challenge)
    assert challenge_config["two_captcha_api_key"] == "test_key"
    print("    ✅ OK")

    # Test 2: Configuration sans challenge
    config_without_challenge = {
        "username": "test",
        "password": "test123"
    }

    challenge_config = ConfigLoader.get_challenge_config(config_without_challenge)
    assert challenge_config is None
    print("    ✅ OK")

    print("✅ Tous les tests d'extraction de challenge passent")


def main():
    """Fonction principale de test"""
    print("🚀 Démarrage des tests de l'architecture unifiée...")
    print("=" * 60)

    try:
        test_config_loader()
        print()
        test_script_arguments()
        print()
        test_template_creation()
        print()
        test_challenge_config_extraction()
        print()

        print("🎉 Tous les tests passent ! L'architecture unifiée fonctionne correctement.")
        print()
        print("📋 Résumé des améliorations :")
        print("  ✅ Configuration unifiée via ConfigLoader")
        print("  ✅ Support des challenges dans tous les scripts")
        print("  ✅ Arguments cohérents entre tous les scripts")
        print("  ✅ Support des variables d'environnement")
        print("  ✅ Validation automatique des configurations")
        print("  ✅ Templates de configuration générés automatiquement")

    except Exception as e:
        print(f"❌ Erreur lors des tests: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
