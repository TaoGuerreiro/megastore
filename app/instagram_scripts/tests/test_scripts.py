#!/usr/bin/env python3
# frozen_string_literal: true
"""
Tests Python natifs pour les scripts Instagram
"""

import sys
import json
import tempfile
import os
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock

# Ajouter le répertoire parent au path pour les imports
sys.path.append(str(Path(__file__).parent.parent))

from core import ConfigLoader, ErrorHandler, InstagramClient, InstagramLogger
from services.hashtag_service import HashtagService
from services.user_service import UserService
from services.message_service import MessageService


class TestConfigLoader(unittest.TestCase):
    """Tests pour le ConfigLoader"""

    def setUp(self):
        self.test_config = {
            "username": "test_user",
            "password": "test_password",
            "challenge_config": {
                "two_captcha_api_key": "test_key"
            }
        }

    def test_load_from_args(self):
        """Test du chargement depuis les arguments"""
        config = ConfigLoader.load_from_args("test_user", "test_password")

        self.assertEqual(config["username"], "test_user")
        self.assertEqual(config["password"], "test_password")
        self.assertIn("challenge_config", config)

    def test_load_from_file(self):
        """Test du chargement depuis un fichier"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            json.dump(self.test_config, f)
            temp_file = f.name

        try:
            config = ConfigLoader.load_from_file(temp_file)
            self.assertEqual(config["username"], "test_user")
            self.assertEqual(config["password"], "test_password")
        finally:
            os.unlink(temp_file)

    def test_validate_config(self):
        """Test de la validation de configuration"""
        # Test valide
        self.assertTrue(ConfigLoader.validate_config(self.test_config))

        # Test invalide - username manquant
        invalid_config = self.test_config.copy()
        del invalid_config["username"]

        with self.assertRaises(ValueError):
            ConfigLoader.validate_config(invalid_config)

    def test_get_challenge_config(self):
        """Test de l'extraction de la configuration de challenge"""
        challenge_config = ConfigLoader.get_challenge_config(self.test_config)
        self.assertEqual(challenge_config["two_captcha_api_key"], "test_key")

        # Test sans challenge config
        config_without_challenge = {
            "username": "test",
            "password": "test123"
        }
        challenge_config = ConfigLoader.get_challenge_config(config_without_challenge)
        self.assertIsNone(challenge_config)


class TestErrorHandler(unittest.TestCase):
    """Tests pour l'ErrorHandler"""

    def test_handle_error(self):
        """Test de la gestion d'erreur"""
        with self.assertRaises(SystemExit):
            ErrorHandler.handle_error("Test error")

    def test_handle_warning(self):
        """Test de la gestion d'avertissement"""
        # Ne devrait pas lever d'exception
        ErrorHandler.handle_warning("Test warning")

    def test_validate_required_fields(self):
        """Test de la validation des champs requis"""
        data = {"field1": "value1", "field2": "value2"}
        required_fields = ["field1", "field2"]

        # Test valide
        ErrorHandler.validate_required_fields(data, required_fields)

        # Test invalide
        with self.assertRaises(ValueError):
            ErrorHandler.validate_required_fields(data, ["field1", "field3"])


class TestInstagramClient(unittest.TestCase):
    """Tests pour InstagramClient (avec mocks)"""

    @patch('core.client.Client')
    def setUp(self, mock_client):
        self.mock_client_instance = MagicMock()
        mock_client.return_value = self.mock_client_instance

        # Mock de l'authentification
        self.mock_client_instance.login.return_value = True
        self.mock_client_instance.get_timeline_feed.return_value = []

        self.client = InstagramClient("test_user", "test_password")

    def test_validate_user_id(self):
        """Test de la validation d'user_id"""
        # Test valide
        result = self.client.validate_user_id("123456789")
        self.assertEqual(result, 123456789)

        # Test invalide
        with self.assertRaises(ValueError):
            self.client.validate_user_id("invalid")

    def test_validate_username(self):
        """Test de la validation de username"""
        # Test avec @
        result = self.client.validate_username("@test_user")
        self.assertEqual(result, "test_user")

        # Test sans @
        result = self.client.validate_username("test_user")
        self.assertEqual(result, "test_user")

        # Test vide
        with self.assertRaises(ValueError):
            self.client.validate_username("")

    @patch('core.client.Client')
    def test_get_user_id_from_username(self, mock_client):
        """Test de la récupération d'user_id"""
        mock_client_instance = MagicMock()
        mock_client.return_value = mock_client_instance
        mock_client_instance.user_id_from_username.return_value = 123456789

        client = InstagramClient("test_user", "test_password")
        result = client.get_user_id_from_username("test_handle")

        self.assertEqual(result, 123456789)


class TestHashtagService(unittest.TestCase):
    """Tests pour HashtagService"""

    def setUp(self):
        self.mock_client = MagicMock()
        self.mock_logger = MagicMock()
        self.service = HashtagService(self.mock_client, self.mock_logger)

    def test_clean_hashtag_name(self):
        """Test du nettoyage du nom de hashtag"""
        # Test avec #
        result = self.service._clean_hashtag_name("#fashion")
        self.assertEqual(result, "fashion")

        # Test sans #
        result = self.service._clean_hashtag_name("fashion")
        self.assertEqual(result, "fashion")

        # Test vide
        with self.assertRaises(ValueError):
            self.service._clean_hashtag_name("")

    def test_get_hashtag_info(self):
        """Test de la récupération d'infos de hashtag"""
        mock_hashtag_info = MagicMock()
        mock_hashtag_info.id = 123456
        mock_hashtag_info.media_count = 1000
        mock_hashtag_info.profile_pic_url = "http://example.com/pic.jpg"

        self.mock_client.client.hashtag_info_a1.return_value = mock_hashtag_info

        result = self.service.get_hashtag_info("fashion")

        self.assertEqual(result["hashtag_name"], "fashion")
        self.assertEqual(result["hashtag_id"], "123456")
        self.assertEqual(result["media_count"], 1000)


class TestUserService(unittest.TestCase):
    """Tests pour UserService"""

    def setUp(self):
        self.mock_client = MagicMock()
        self.mock_logger = MagicMock()
        self.service = UserService(self.mock_client, self.mock_logger)

    def test_get_user_info(self):
        """Test de la récupération d'infos utilisateur"""
        # Mock des méthodes du client
        self.mock_client.validate_username.return_value = "test_user"
        self.mock_client.get_user_id_from_username.return_value = 123456789

        mock_user_info = MagicMock()
        mock_user_info.pk = 123456789
        mock_user_info.username = "test_user"
        mock_user_info.full_name = "Test User"
        mock_user_info.is_private = False
        mock_user_info.is_verified = False
        mock_user_info.profile_pic_url = "http://example.com/pic.jpg"
        mock_user_info.follower_count = 1000
        mock_user_info.following_count = 500
        mock_user_info.media_count = 50
        mock_user_info.biography = "Test bio"
        mock_user_info.external_url = "http://example.com"

        self.mock_client.client.user_info.return_value = mock_user_info
        self.mock_client.format_user_info.return_value = MagicMock()

        result = self.service.get_user_info("test_user")

        self.mock_client.validate_username.assert_called_with("test_user")
        self.mock_client.get_user_id_from_username.assert_called_with("test_user")


class TestMessageService(unittest.TestCase):
    """Tests pour MessageService"""

    def setUp(self):
        self.mock_client = MagicMock()
        self.mock_logger = MagicMock()
        self.service = MessageService(self.mock_client, self.mock_logger)

    def test_send_message(self):
        """Test de l'envoi de message"""
        # Mock des méthodes du client
        self.mock_client.validate_user_id.return_value = 123456789

        mock_result = MagicMock()
        mock_result.id = "msg_123"
        mock_result.taken_at = None  # Pas de timestamp pour ce test

        self.mock_client.client.direct_send.return_value = mock_result
        self.mock_client.client.user_id = 987654321
        self.mock_client.username = "test_user"

        result = self.service.send_message("123456789", "Test message")

        self.assertTrue(result["success"])
        self.assertEqual(result["recipient_id"], "123456789")
        self.mock_client.client.direct_send.assert_called_with("Test message", [123456789])


class TestScriptsIntegration(unittest.TestCase):
    """Tests d'intégration pour les scripts"""

    def test_script_structure(self):
        """Test de la structure des scripts"""
        scripts_dir = Path(__file__).parent.parent / "scripts"

        required_scripts = [
            "fetch_user_id.py",
            "search_hashtags.py",
            "send_message.py",
            "fetch_messages.py",
            "fetch_followers.py",
            "like_posts.py",
            "engagement.py"
        ]

        for script in required_scripts:
            script_path = scripts_dir / script
            self.assertTrue(script_path.exists(), f"Script {script} manquant")
            self.assertTrue(os.access(script_path, os.R_OK), f"Script {script} non lisible")

    def test_python_dependencies(self):
        """Test des dépendances Python"""
        required_modules = [
            'instagrapi',
            'requests',
            'json',
            'argparse',
            'pathlib',
            'datetime',
            'tempfile',
            'os',
            'sys'
        ]

        missing_modules = []
        for module in required_modules:
            try:
                __import__(module)
            except ImportError:
                missing_modules.append(module)

        self.assertEqual(len(missing_modules), 0,
                        f"Modules Python manquants: {', '.join(missing_modules)}")


def run_tests():
    """Exécuter tous les tests"""
    # Créer un test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    # Ajouter tous les tests
    test_classes = [
        TestConfigLoader,
        TestErrorHandler,
        TestInstagramClient,
        TestHashtagService,
        TestUserService,
        TestMessageService,
        TestScriptsIntegration
    ]

    for test_class in test_classes:
        tests = loader.loadTestsFromTestCase(test_class)
        suite.addTests(tests)

    # Exécuter les tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    # Retourner le résultat en JSON
    return {
        "tests_run": result.testsRun,
        "failures": len(result.failures),
        "errors": len(result.errors),
        "success": result.wasSuccessful(),
        "failure_details": [str(failure) for failure in result.failures],
        "error_details": [str(error) for error in result.errors]
    }


if __name__ == "__main__":
    result = run_tests()
    print(json.dumps(result, indent=2))

    # Code de sortie basé sur le succès
    sys.exit(0 if result["success"] else 1)
