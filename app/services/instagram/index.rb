# frozen_string_literal: true

module Instagram
  # Index des services Instagram
  #
  # Ce module contient tous les services Instagram refactorisés et unifiés.
  # Chaque service hérite de BaseService et utilise la nouvelle architecture modulaire.

  # Services disponibles :
  #
  # 1. BaseService - Service de base avec utilitaires communs
  #    - Gestion des scripts Python
  #    - Validation des credentials
  #    - Gestion d'erreurs et logging
  #
  # 2. FetchUserIdService - Récupération d'ID utilisateur
  #    - Utilise fetch_user_id.py
  #    - Validation des paramètres
  #    - Retourne l'ID utilisateur
  #
  # 3. FetchMessagesService - Récupération de messages
  #    - Utilise fetch_messages.py
  #    - Support des heures de recherche
  #    - Retourne la liste des messages
  #
  # 4. SendMessageService - Envoi de messages
  #    - Utilise send_message.py
  #    - Validation du message
  #    - Retourne les informations du message envoyé
  #
  # 5. EngagementService - Gestion de l'engagement
  #    - Utilise engagement.py (nouveau script unifié)
  #    - Support des hashtags et comptes ciblés
  #    - Gestion des cursors et statistiques
  #
  # Utilisation :
  #
  # ```ruby
  # # Récupérer un ID utilisateur
  # user_id = Instagram::FetchUserIdService.call(
  #   username: "user",
  #   password: "pass",
  #   handle: "target_user"
  # )
  #
  # # Récupérer des messages
  # messages = Instagram::FetchMessagesService.call(
  #   username: "user",
  #   password: "pass",
  #   recipient_id: "123456789",
  #   hours_back: 24
  # )
  #
  # # Envoyer un message
  # result = Instagram::SendMessageService.call(
  #   username: "user",
  #   password: "pass",
  #   recipient_id: "123456789",
  #   message: "Hello!"
  # )
  #
  # # Engagement automatisé
  # result = Instagram::EngagementService.call_from_user(
  #   user,
  #   user.instagram_username,
  #   user.instagram_password,
  #   social_campagne: campaign
  # )
  # ```

  # Charger tous les services
  require_relative "base_service"
  require_relative "fetch_user_id_service"
  require_relative "fetch_messages_service"
  require_relative "send_message_service"
  require_relative "engagement_service"

  # S'assurer que l'index est chargé
  def self.load_index
  end

  # Services publics
  SERVICES = {
    fetch_user_id: FetchUserIdService,
    fetch_messages: FetchMessagesService,
    send_message: SendMessageService,
    engagement: EngagementService
  }.freeze

  # Méthodes utilitaires
  class << self
    def available_services
      SERVICES.keys
    end

    def service_exists?(service_name)
      SERVICES.key?(service_name.to_sym)
    end

    def get_service(service_name)
      SERVICES[service_name.to_sym]
    end

    def test_all_services
      results = {}

      SERVICES.each do |name, service_class|
        # Test basique de la classe
        results[name] = if service_class.respond_to?(:call)
                          { status: :ok, message: "Service disponible" }
                        else
                          { status: :error, message: "Méthode call manquante" }
                        end
      rescue StandardError => e
        results[name] = { status: :error, message: e.message }
      end

      results
    end
  end
end
