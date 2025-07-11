# frozen_string_literal: true
"""
Module de gestion d'erreurs standardisée pour les scripts Instagram
"""

import sys
import json
from typing import Optional, Dict, Any


class ErrorHandler:
    """Gestionnaire d'erreurs standardisé"""

    @staticmethod
    def handle_error(error_message: str, context: Optional[Dict[str, Any]] = None, exit_code: int = 1):
        """
        Gérer une erreur de manière standardisée

        Args:
            error_message: Message d'erreur
            context: Contexte supplémentaire (optionnel)
            exit_code: Code de sortie (défaut: 1)
        """
        error_data = {"error": error_message}

        if context:
            error_data["context"] = context

        print(json.dumps(error_data, ensure_ascii=False, indent=2))
        sys.exit(exit_code)

    @staticmethod
    def handle_warning(warning_message: str, context: Optional[Dict[str, Any]] = None):
        """
        Gérer un avertissement de manière standardisée

        Args:
            warning_message: Message d'avertissement
            context: Contexte supplémentaire (optionnel)
        """
        warning_data = {"warning": warning_message}

        if context:
            warning_data["context"] = context

        print(json.dumps(warning_data, ensure_ascii=False, indent=2), file=sys.stderr)

    @staticmethod
    def handle_info(info_message: str, context: Optional[Dict[str, Any]] = None):
        """
        Gérer une information de manière standardisée

        Args:
            info_message: Message d'information
            context: Contexte supplémentaire (optionnel)
        """
        info_data = {"info": info_message}

        if context:
            info_data["context"] = context

        print(json.dumps(info_data, ensure_ascii=False, indent=2))

    @staticmethod
    def handle_success(success_message: str, data: Optional[Dict[str, Any]] = None):
        """
        Gérer un succès de manière standardisée

        Args:
            success_message: Message de succès
            data: Données supplémentaires (optionnel)
        """
        success_data = {"success": success_message}

        if data:
            success_data["data"] = data

        print(json.dumps(success_data, ensure_ascii=False, indent=2))

    @staticmethod
    def validate_required_fields(data: Dict[str, Any], required_fields: list, source: str = "configuration"):
        """
        Valider la présence de champs requis

        Args:
            data: Données à valider
            required_fields: Liste des champs requis
            source: Source des données (pour le message d'erreur)

        Raises:
            ValueError: Si un champ requis est manquant
        """
        missing_fields = []

        for field in required_fields:
            if field not in data or not data[field]:
                missing_fields.append(field)

        if missing_fields:
            raise ValueError(f"Champs requis manquants dans {source}: {', '.join(missing_fields)}")

    @staticmethod
    def safe_execute(func, *args, error_message: str = "Erreur lors de l'exécution", **kwargs):
        """
        Exécuter une fonction de manière sécurisée avec gestion d'erreur

        Args:
            func: Fonction à exécuter
            *args: Arguments de la fonction
            error_message: Message d'erreur personnalisé
            **kwargs: Arguments nommés de la fonction

        Returns:
            Résultat de la fonction ou None en cas d'erreur
        """
        try:
            return func(*args, **kwargs)
        except Exception as e:
            ErrorHandler.handle_error(f"{error_message}: {str(e)}")
            return None
