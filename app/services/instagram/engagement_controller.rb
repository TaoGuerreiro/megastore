# frozen_string_literal: true

require "open3"
require "json"

module Instagram
  # Service pour lancer le contrôleur d'engagement Instagram
  #
  # Exemple d'utilisation :
  #
  # # Avec des SocialTargets (recommandé)
  # user = User.find(1)
  # result = Instagram::EngagementController.call_from_user(user, "username", "password")
  #
  # # Avec une configuration manuelle
  # config = [
  #   {
  #     "username" => "unsafehc",
  #     "password" => "password123",
  #     "hashtags" => ["counterparts", "nantes"],
  #     "targeted_accounts" => ["counterpartsband", "chalky_mood"]
  #   }
  # ]
  # result = Instagram::EngagementController.call(config)
  class EngagementController
    SCRIPT_PATH = Rails.root.join("app/instagram_scripts/instagram_engagement_controller.py").to_s

    def self.call(accounts_config, campagne_id = nil)
      # Validation de la configuration
      validate_config(accounts_config)

      # Formater la configuration selon le nouveau format
      formatted_config = format_config(accounts_config)

      # Créer un fichier de configuration temporaire
      config_file = create_temp_config(formatted_config)

      begin
        # Lancer le script Python
        result = execute_script(config_file.path, campagne_id)

        # Parser et retourner le résultat
        parse_result(result)
      ensure
        # Nettoyer le fichier temporaire
        config_file.close
        config_file.unlink
      end
    end

    # Nouvelle méthode pour utiliser les SocialTargets
    def self.call_from_user(user, username, password, hashtags: nil, targeted_accounts: nil, social_campagne: nil)
      # Si social_campagne est fourni, l'utiliser, sinon utiliser la campagne par défaut de l'utilisateur
      campagne = social_campagne || user.social_campagne

      # hashtags et targeted_accounts sont maintenant des arrays de hashes {"name", "kind", "cursor"}
      hashtags ||= campagne&.social_targets&.where(kind: "hashtag")&.map do |h|
        h.slice("name", "kind", "cursor")
      end || []
      targeted_accounts ||= campagne&.social_targets&.where(kind: "account")&.map do |a|
        a.slice("name", "kind", "cursor")
      end || []

      config = [
        {
          "username" => username,
          "password" => password,
          "hashtags" => hashtags.map { |h| { "hashtag" => h["name"], "cursor" => h["cursor"] } },
          "targeted_accounts" => targeted_accounts.map { |a| { "account" => a["name"], "cursor" => a["cursor"] } }
        }
      ]

      result = call(config, campagne&.id)
      update_cursors_from_result(result, user, campagne)
      result
    end

    # Méthode pour récupérer la configuration actuelle d'un utilisateur
    def self.get_user_config(user)
      hashtags = user.social_targets.where(kind: "hashtag")
      targeted_accounts = user.social_targets.where(kind: "account")

      {
        "hashtags" => hashtags.map { |st| { "hashtag" => st.name, "cursor" => st.cursor } },
        "targeted_accounts" => targeted_accounts.map { |st| { "account" => st.name, "cursor" => st.cursor } }
      }
    end

    # Méthode pour créer ou mettre à jour les SocialTargets d'un utilisateur
    def self.update_user_targets(user, hashtags: [], targeted_accounts: [])
      # Mettre à jour les hashtags
      hashtags.each do |hashtag|
        if hashtag.is_a?(Hash)
          st = user.social_targets.find_or_create_by(kind: "hashtag", name: hashtag["hashtag"])
          st.update(cursor: hashtag["cursor"]) if hashtag["cursor"]
        else
          user.social_targets.find_or_create_by(kind: "hashtag", name: hashtag)
        end
      end

      # Mettre à jour les comptes ciblés
      targeted_accounts.each do |account|
        if account.is_a?(Hash)
          st = user.social_targets.find_or_create_by(kind: "account", name: account["account"])
          st.update(cursor: account["cursor"]) if account["cursor"]
        else
          user.social_targets.find_or_create_by(kind: "account", name: account)
        end
      end
    end

    private

    def self.update_cursors_from_result(result, user, campagne = nil)
      return unless result["sessions"]&.any?

      # Utiliser la campagne fournie ou la campagne par défaut de l'utilisateur
      campagne ||= user.social_campagne
      return unless campagne

      # Prendre la dernière session (la plus récente)
      session = result["sessions"].last
      return unless session

      # Mettre à jour les cursors des hashtags
      if session["hashtag_likes"]
        session["hashtag_likes"].each do |hashtag_name, data|
          next unless data["cursor"]

          social_target = campagne.social_targets.find_or_create_by(kind: "hashtag", name: hashtag_name)
          social_target.update(cursor: data["cursor"])
        end
      end

      # Mettre à jour les cursors des comptes ciblés
      if session["follower_likes"]
        session["follower_likes"].each do |account_name, data|
          next unless data["cursor"]

          social_target = campagne.social_targets.find_or_create_by(kind: "account", name: account_name)
          social_target.update(cursor: data["cursor"])
        end
      end

      # Mettre à jour les statistiques si disponibles
      update_stats_from_result(result, user, campagne)
    end

    def self.update_stats_from_result(result, user, campagne = nil)
      return unless result["sessions"]&.any?

      # Utiliser la campagne fournie ou la campagne par défaut de l'utilisateur
      campagne ||= user.social_campagne
      return unless campagne

      session = result["sessions"].last
      return unless session

      # Mettre à jour les statistiques des hashtags
      if session["hashtag_likes"]
        session["hashtag_likes"].each do |hashtag_name, data|
          social_target = campagne.social_targets.find_by(kind: "hashtag", name: hashtag_name)
          next unless social_target

          # Ici on pourrait ajouter des champs pour les statistiques si nécessaire
          # social_target.update(
          #   total_likes: data["successful"],
          #   last_activity: Time.current
          # )
        end
      end

      # Mettre à jour les statistiques des comptes ciblés
      return unless session["follower_likes"]

      session["follower_likes"].each do |account_name, data|
        social_target = campagne.social_targets.find_by(kind: "account", name: account_name)
        next unless social_target

        # Ici on pourrait ajouter des champs pour les statistiques si nécessaire
        # social_target.update(
        #   total_likes: data["likes"],
        #   followers_processed: data["followers_processed"],
        #   last_activity: Time.current
        # )
      end
    end

    def self.validate_config(accounts_config)
      raise ArgumentError, "accounts_config doit être un array" unless accounts_config.is_a?(Array)
      raise ArgumentError, "accounts_config ne peut pas être vide" if accounts_config.empty?

      accounts_config.each_with_index do |account, index|
        validate_account_config(account, index)
      end
    end

    def self.validate_account_config(account, index)
      required_fields = %w[username password hashtags targeted_accounts]

      required_fields.each do |field|
        raise ArgumentError, "Compte #{index}: champ '#{field}' manquant" unless account.key?(field)
      end

      raise ArgumentError, "Compte #{index}: username ne peut pas être vide" if account["username"].blank?
      raise ArgumentError, "Compte #{index}: password ne peut pas être vide" if account["password"].blank?
      raise ArgumentError, "Compte #{index}: hashtags doit être un array" unless account["hashtags"].is_a?(Array)

      unless account["targeted_accounts"].is_a?(Array)
        raise ArgumentError,
              "Compte #{index}: targeted_accounts doit être un array"
      end

      return unless account["hashtags"].empty? && account["targeted_accounts"].empty?

      raise ArgumentError, "Compte #{index}: au moins un hashtag ou un compte cible doit être spécifié"

      # Valider la structure des hashtags
      validate_hashtags_structure(account["hashtags"], index)

      # Valider la structure des comptes ciblés
      validate_targeted_accounts_structure(account["targeted_accounts"], index)
    end

    def self.validate_hashtags_structure(hashtags, account_index)
      hashtags.each_with_index do |hashtag, hashtag_index|
        if hashtag.is_a?(Hash)
          unless hashtag.key?("hashtag")
            raise ArgumentError, "Compte #{account_index}: hashtag #{hashtag_index}: champ 'hashtag' manquant"
          end

          if hashtag["hashtag"].blank?
            raise ArgumentError,
                  "Compte #{account_index}: hashtag #{hashtag_index}: hashtag ne peut pas être vide"
          end
        elsif hashtag.is_a?(String)
          if hashtag.blank?
            raise ArgumentError,
                  "Compte #{account_index}: hashtag #{hashtag_index}: hashtag ne peut pas être vide"
          end
        else
          raise ArgumentError, "Compte #{account_index}: hashtag #{hashtag_index}: doit être un string ou un hash"
        end
      end
    end

    def self.validate_targeted_accounts_structure(targeted_accounts, account_index)
      targeted_accounts.each_with_index do |account, account_target_index|
        if account.is_a?(Hash)
          unless account.key?("account")
            raise ArgumentError,
                  "Compte #{account_index}: compte cible #{account_target_index}: champ 'account' manquant"
          end
          if account["account"].blank?
            raise ArgumentError,
                  "Compte #{account_index}: compte cible #{account_target_index}: account ne peut pas être vide"
          end
        elsif account.is_a?(String)
          if account.blank?
            raise ArgumentError,
                  "Compte #{account_index}: compte cible #{account_target_index}: account ne peut pas être vide"
          end
        else
          raise ArgumentError,
                "Compte #{account_index}: compte cible #{account_target_index}: doit être un string ou un hash"
        end
      end
    end

    def self.format_config(accounts_config)
      accounts_config.map do |account|
        {
          "username" => account["username"],
          "password" => account["password"],
          "hashtags" => format_hashtags(account["hashtags"]),
          "targeted_accounts" => format_targeted_accounts(account["targeted_accounts"])
        }
      end
    end

    def self.format_hashtags(hashtags)
      hashtags.map do |hashtag|
        if hashtag.is_a?(Hash)
          {
            "hashtag" => hashtag["hashtag"],
            "cursor" => hashtag["cursor"]
          }
        else
          {
            "hashtag" => hashtag,
            "cursor" => nil
          }
        end
      end
    end

    def self.format_targeted_accounts(targeted_accounts)
      targeted_accounts.map do |account|
        if account.is_a?(Hash)
          {
            "account" => account["account"],
            "cursor" => account["cursor"]
          }
        else
          {
            "account" => account,
            "cursor" => nil
          }
        end
      end
    end

    def self.create_temp_config(accounts_config)
      # Créer un fichier temporaire avec la configuration
      config_file = Tempfile.new(["engagement_config", ".json"])
      config_file.write(accounts_config.to_json)
      config_file.rewind
      config_file
    end

    def self.execute_script(config_file_path, campagne_id = nil)
      python_executable = if Rails.env.production?
                            "python3"
                          else
                            "venv/bin/python"
                          end

      cmd = [python_executable, SCRIPT_PATH, config_file_path]
      cmd << campagne_id.to_s if campagne_id

      # Préparer l'environnement avec les variables nécessaires
      env = ENV.to_hash

      # Déterminer l'URL de l'API
      api_url = if Rails.env.production?
                  "https://www.unsafehxc.fr/" # À adapter selon votre domaine
                elsif Rails.env.development?
                  # Utiliser l'URL ngrok si disponible, sinon localhost
                  ENV.fetch("NGROK_URL", "http://localhost:3000")
                else
                  ENV.fetch("SOCIAL_CAMPAIGN_API_URL", "http://localhost:3000")
                end

      env["SOCIAL_CAMPAIGN_API_URL"] = api_url
      env["SOCIAL_CAMPAIGN_API_TOKEN"] =
        Rails.application.credentials.social_campaign_token || ENV.fetch("SOCIAL_CAMPAIGN_API_TOKEN", nil)

      # Exécuter le script Python avec l'environnement
      stdout, stderr, status = Open3.capture3(env, *cmd)

      raise StandardError, "Erreur engagement controller Instagram: #{stderr}" unless status.success?

      stdout
    end

    def self.parse_result(output)
      # Le script Python affiche plusieurs lignes JSON (logs + rapport final)
      lines = output.strip.split("\n")

      # Le dernier JSON est le rapport final
      final_report = lines.last

      begin
        JSON.parse(final_report)
      rescue JSON::ParserError => e
        raise StandardError, "Erreur parsing rapport final: #{e.message}"
      end
    end
  end
end
