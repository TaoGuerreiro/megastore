# frozen_string_literal: true
"""
Service pour la gestion des messages Instagram
"""

from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional, Union
from core.client import InstagramClient
from core.logger import InstagramLogger


class MessageService:
    """Service pour la gestion des messages Instagram"""

    def __init__(self, client: InstagramClient, logger: InstagramLogger):
        """
        Initialiser le service message

        Args:
            client: Client Instagram authentifié
            logger: Logger pour tracer les actions
        """
        self.client = client
        self.logger = logger

    def send_message(self, recipient_id: Union[str, int], message: str) -> Dict[str, Any]:
        """
        Envoyer un message privé

        Args:
            recipient_id: ID de l'utilisateur destinataire
            message: Contenu du message

        Returns:
            Informations du message envoyé
        """
        try:
            # Validation du recipient_id
            user_id = self.client.validate_user_id(recipient_id)

            # Envoi du message
            result = self.client.client.direct_send(message, [user_id])

            # Récupération des informations du message
            instagram_timestamp = None
            if hasattr(result, 'taken_at') and result.taken_at:
                instagram_timestamp = result.taken_at.isoformat()
            elif hasattr(result, 'timestamp') and result.timestamp:
                if hasattr(result.timestamp, 'isoformat'):
                    instagram_timestamp = result.timestamp.isoformat()
                else:
                    instagram_timestamp = str(result.timestamp)

            message_info = {
                "success": True,
                "message": "Message envoyé avec succès",
                "instagram_message_id": str(result.id) if hasattr(result, 'id') else None,
                "instagram_sender_id": str(self.client.client.user_id) if hasattr(self.client.client, 'user_id') else None,
                "instagram_sender_username": self.client.username,
                "instagram_timestamp": instagram_timestamp,
                "recipient_id": str(user_id)
            }

            self.logger.log_action("send_message", {
                "recipient_id": str(user_id),
                "message_length": len(message),
                "instagram_message_id": message_info["instagram_message_id"]
            })

            return message_info

        except Exception as e:
            self.logger.log_error(f"Erreur lors de l'envoi du message: {str(e)}")
            raise

    def get_messages(self, recipient_id: Union[str, int], hours_back: float = 24) -> List[Dict[str, Any]]:
        """
        Récupérer les messages d'une conversation

        Args:
            recipient_id: ID de l'utilisateur
            hours_back: Nombre d'heures en arrière pour filtrer les messages

        Returns:
            Liste des messages
        """
        try:
            # Validation des paramètres
            if hours_back < 0 or hours_back > 8760:  # Max 1 an
                raise ValueError("hours_back doit être entre 0 et 8760")

            user_id = self.client.validate_user_id(recipient_id)
            cutoff_time = datetime.now() - timedelta(hours=hours_back)

            # Récupération des threads
            inbox = self.client.client.direct_threads()
            target_thread = None

            # Rechercher le thread avec l'utilisateur
            for thread in inbox:
                user_pks = [u.pk for u in thread.users]
                if any(str(u.pk) == str(user_id) for u in thread.users):
                    target_thread = thread
                    break

            if not target_thread:
                raise Exception("Aucun thread trouvé pour ce user_id")

            # Récupération des messages
            messages = self.client.client.direct_messages(target_thread.id, amount=50)
            messages_data = []

            for message in messages:
                message_time = message.timestamp
                if message_time >= cutoff_time:
                    message_data = {
                        "thread_id": str(target_thread.id),
                        "message_id": str(message.id),
                        "sender_id": str(message.user_id),
                        "sender_username": None,  # Pas récupéré côté Python
                        "sender_full_name": None,
                        "text": message.text,
                        "timestamp": str(message.timestamp),
                        "datetime": message_time.isoformat()
                    }
                    messages_data.append(message_data)

            self.logger.log_action("get_messages", {
                "recipient_id": str(user_id),
                "thread_id": str(target_thread.id),
                "messages_count": len(messages_data),
                "hours_back": hours_back
            })

            return messages_data

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des messages: {str(e)}")
            raise

    def get_all_threads(self) -> List[Dict[str, Any]]:
        """
        Récupérer tous les threads de messages

        Returns:
            Liste des threads
        """
        try:
            inbox = self.client.client.direct_threads()
            threads_data = []

            for thread in inbox:
                thread_data = {
                    "thread_id": str(thread.id),
                    "users": [
                        {
                            "user_id": str(user.pk),
                            "username": user.username,
                            "full_name": user.full_name
                        }
                        for user in thread.users
                    ],
                    "last_activity": str(thread.last_activity) if hasattr(thread, 'last_activity') else None,
                    "unseen_count": getattr(thread, 'unseen_count', 0)
                }
                threads_data.append(thread_data)

            self.logger.log_action("get_all_threads", {
                "threads_count": len(threads_data)
            })

            return threads_data

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la récupération des threads: {str(e)}")
            raise

    def mark_thread_as_seen(self, thread_id: Union[str, int]) -> Dict[str, Any]:
        """
        Marquer un thread comme vu

        Args:
            thread_id: ID du thread

        Returns:
            Résultat de l'action
        """
        try:
            # Marquer comme vu
            self.client.client.direct_thread_seen(thread_id)

            result = {
                "success": True,
                "thread_id": str(thread_id),
                "message": "Thread marqué comme vu"
            }

            self.logger.log_action("mark_thread_seen", {
                "thread_id": str(thread_id)
            })

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors du marquage du thread comme vu: {str(e)}")
            raise

    def delete_message(self, message_id: Union[str, int]) -> Dict[str, Any]:
        """
        Supprimer un message

        Args:
            message_id: ID du message

        Returns:
            Résultat de l'action
        """
        try:
            # Supprimer le message
            self.client.client.direct_message_delete(message_id)

            result = {
                "success": True,
                "message_id": str(message_id),
                "message": "Message supprimé avec succès"
            }

            self.logger.log_action("delete_message", {
                "message_id": str(message_id)
            })

            return result

        except Exception as e:
            self.logger.log_error(f"Erreur lors de la suppression du message: {str(e)}")
            raise
