# frozen_string_literal: true
"""
Système de logging unifié pour les scripts Instagram
"""

import os
import json
import logging
from datetime import datetime
from typing import Dict, Any, Optional
from pathlib import Path


class InstagramLogger:
    """Logger unifié pour les scripts Instagram avec sauvegarde JSON"""

    def __init__(self, username: str, log_dir: str = "logs"):
        """
        Initialiser le logger

        Args:
            username: Nom d'utilisateur pour identifier les logs
            log_dir: Répertoire de sauvegarde des logs
        """
        self.username = username
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(exist_ok=True)

        # Créer le fichier de log avec timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_file = self.log_dir / f"instagram_{username}_{timestamp}.json"

        # Initialiser le fichier de log
        self._init_log_file()

        # Configurer le logging Python standard
        self._setup_python_logging()

    def _init_log_file(self):
        """Initialiser le fichier de log JSON"""
        log_data = {
            "username": self.username,
            "session_start": datetime.now().isoformat(),
            "logs": [],
            "stats": {
                "total_actions": 0,
                "successful_actions": 0,
                "failed_actions": 0,
                "errors": []
            }
        }

        with open(self.log_file, 'w', encoding='utf-8') as f:
            json.dump(log_data, f, indent=2, ensure_ascii=False)

    def _setup_python_logging(self):
        """Configurer le logging Python standard"""
        # Créer un logger spécifique pour cet utilisateur
        self.logger = logging.getLogger(f"Instagram.{self.username}")
        self.logger.setLevel(logging.INFO)

        # Éviter les handlers multiples
        if not self.logger.handlers:
            # Handler pour la console
            console_handler = logging.StreamHandler()
            console_handler.setLevel(logging.INFO)

            # Format personnalisé
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            console_handler.setFormatter(formatter)

            self.logger.addHandler(console_handler)

    def log_action(self, action_type: str, details: Dict[str, Any], success: bool = True):
        """
        Logger une action

        Args:
            action_type: Type d'action (like, follow, message, etc.)
            details: Détails de l'action
            success: Si l'action a réussi
        """
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "action_type": action_type,
            "success": success,
            "details": details
        }

        # Ajouter au fichier JSON
        self._append_to_log_file(log_entry)

        # Logger avec Python logging
        level = logging.INFO if success else logging.ERROR
        message = f"{action_type}: {'Succès' if success else 'Échec'} - {details}"
        self.logger.log(level, message)

        # Mettre à jour les stats
        self._update_stats(success)

    def log_error(self, error_message: str, context: Optional[Dict[str, Any]] = None):
        """Logger une erreur"""
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "action_type": "error",
            "success": False,
            "details": {
                "error_message": error_message,
                "context": context or {}
            }
        }

        self._append_to_log_file(log_entry)
        self.logger.error(f"Erreur: {error_message}")
        self._update_stats(False, error_message)

    def log_info(self, message: str, context: Optional[Dict[str, Any]] = None):
        """Logger une information"""
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "action_type": "info",
            "success": True,
            "details": {
                "message": message,
                "context": context or {}
            }
        }

        self._append_to_log_file(log_entry)
        self.logger.info(message)

    def _append_to_log_file(self, log_entry: Dict[str, Any]):
        """Ajouter une entrée au fichier de log JSON"""
        try:
            # Lire le fichier existant
            with open(self.log_file, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Ajouter la nouvelle entrée
            data["logs"].append(log_entry)

            # Réécrire le fichier
            with open(self.log_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)

        except Exception as e:
            # En cas d'erreur, afficher sur stderr
            print(f"Erreur lors de l'écriture du log: {e}", file=os.sys.stderr)

    def _update_stats(self, success: bool, error_message: Optional[str] = None):
        """Mettre à jour les statistiques"""
        try:
            with open(self.log_file, 'r', encoding='utf-8') as f:
                data = json.load(f)

            data["stats"]["total_actions"] += 1

            if success:
                data["stats"]["successful_actions"] += 1
            else:
                data["stats"]["failed_actions"] += 1
                if error_message:
                    data["stats"]["errors"].append({
                        "timestamp": datetime.now().isoformat(),
                        "message": error_message
                    })

            with open(self.log_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)

        except Exception as e:
            print(f"Erreur lors de la mise à jour des stats: {e}", file=os.sys.stderr)

    def get_stats(self) -> Dict[str, Any]:
        """Obtenir les statistiques actuelles"""
        try:
            with open(self.log_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            return data["stats"]
        except Exception:
            return {
                "total_actions": 0,
                "successful_actions": 0,
                "failed_actions": 0,
                "errors": []
            }

    def print_summary(self):
        """Afficher un résumé des actions"""
        stats = self.get_stats()
        success_rate = (stats["successful_actions"] / stats["total_actions"] * 100) if stats["total_actions"] > 0 else 0

        summary = {
            "username": self.username,
            "log_file": str(self.log_file),
            "total_actions": stats["total_actions"],
            "successful_actions": stats["successful_actions"],
            "failed_actions": stats["failed_actions"],
            "success_rate": f"{success_rate:.1f}%",
            "errors_count": len(stats["errors"])
        }

        print(json.dumps(summary, ensure_ascii=False, indent=2))
