# frozen_string_literal: true

require "tempfile"

module Instagram
  # Service pour l'engagement Instagram
  class EngagementService < BaseService
    def self.call(accounts_config, campagne_id = nil)
      validate_config(accounts_config)

      # Créer un fichier de configuration temporaire
      config_file = create_temp_config(accounts_config)

      begin
        # Utiliser la méthode unifiée de BaseService
        args = [config_file.path]
        args << "--campagne-id" << campagne_id.to_s if campagne_id.present?

        result = execute_script("engagement.py", *args)

        # Parser et retourner le résultat
        parse_result(result)
      ensure
        # Nettoyer le fichier temporaire
        config_file.close
        config_file.unlink
      end
    end

    # Méthode pour utiliser les SocialTargets
    def self.call_from_user(user, username, password, hashtags: nil, targeted_accounts: nil, social_campagne: nil)
      campagne = social_campagne || user.social_campagne

      # Récupérer les hashtags et comptes ciblés avec leurs IDs
      hashtags ||= campagne&.social_targets&.where(kind: "hashtag")&.map do |h|
        {
          "hashtag" => h.name,
          "cursor" => h.cursor,
          "social_target_id" => h.id,
          "social_campagne_id" => campagne.id
        }
      end || []

      targeted_accounts ||= campagne&.social_targets&.where(kind: "account")&.map do |a|
        {
          "account" => a.name,
          "cursor" => a.cursor,
          "social_target_id" => a.id,
          "social_campagne_id" => campagne.id
        }
      end || []

      config = [
        {
          "username" => username,
          "password" => password,
          "hashtags" => hashtags,
          "targeted_accounts" => targeted_accounts,
          "social_campagne_id" => campagne&.id
        }
      ]

      result = call(config, campagne&.id)
      update_cursors_from_result(result, user, campagne)
      result
    end

    # Méthode pour récupérer la configuration actuelle d'un utilisateur
    def self.get_user_config(user)
      campagne = user.social_campagne
      return { "hashtags" => [], "targeted_accounts" => [] } unless campagne

      hashtags = campagne.social_targets.where(kind: "hashtag")
      targeted_accounts = campagne.social_targets.where(kind: "account")

      {
        "hashtags" => hashtags.map do |st|
                        {
                          "hashtag" => st.name,
                          "cursor" => st.cursor,
                          "social_target_id" => st.id,
                          "social_campagne_id" => st.social_campagne_id
                        }
                      end,
        "targeted_accounts" => targeted_accounts.map do |st|
                                 {
                                   "account" => st.name,
                                   "cursor" => st.cursor,
                                   "social_target_id" => st.id,
                                   "social_campagne_id" => st.social_campagne_id
                                 }
                               end
      }
    end

    # Méthode pour créer ou mettre à jour les SocialTargets d'un utilisateur
    def self.update_user_targets(user, hashtags: [], targeted_accounts: [])
      campagne = user.social_campagne || user.create_social_campagne!(status: "active", name: "Campagne principale")

      # Mettre à jour les hashtags
      hashtags.each do |hashtag|
        if hashtag.is_a?(Hash)
          st = campagne.social_targets.find_or_create_by(kind: "hashtag", name: hashtag["hashtag"])
          st.update(cursor: hashtag["cursor"]) if hashtag["cursor"]
        else
          campagne.social_targets.find_or_create_by(kind: "hashtag", name: hashtag)
        end
      end

      # Mettre à jour les comptes ciblés
      targeted_accounts.each do |account|
        if account.is_a?(Hash)
          st = campagne.social_targets.find_or_create_by(kind: "account", name: account["account"])
          st.update(cursor: account["cursor"]) if account["cursor"]
        else
          campagne.social_targets.find_or_create_by(kind: "account", name: account)
        end
      end
    end

    private

    def self.create_temp_config(accounts_config)
      # Ajouter la configuration de challenge à chaque compte
      accounts_with_challenge = accounts_config.map do |account|
        account.merge("challenge_config" => ChallengeConfigurable.get_challenge_config)
      end

      config_file = Tempfile.new(["engagement_config", ".json"])
      config_file.write(accounts_with_challenge.to_json)
      config_file.rewind
      config_file
    end

    def self.parse_result(result)
      # Le script Python retourne maintenant directement un hash JSON
      # Plus besoin de parser plusieurs lignes
      result
    end

    def self.update_cursors_from_result(result, user, campagne = nil)
      return unless result["sessions"]&.any?

      campagne ||= user.social_campagne
      return unless campagne

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

      update_stats_from_result(result, user, campagne)
    end

    def self.update_stats_from_result(result, user, campagne = nil)
      return unless result["sessions"]&.any?

      campagne ||= user.social_campagne
      return unless campagne

      session = result["sessions"].last
      return unless session

      # Mettre à jour les statistiques des hashtags
      if session["hashtag_likes"]
        session["hashtag_likes"].each do |hashtag_name, data|
          social_target = campagne.social_targets.find_by(kind: "hashtag", name: hashtag_name)
          next unless social_target

          # Mettre à jour les statistiques
          posts_liked = data["posts_liked"] || []
          total_likes = data["successful"] || 0

          social_target.update!(
            total_likes:,
            posts_liked:,
            last_activity: Time.current
          )
        end
      end

      # Mettre à jour les statistiques des comptes ciblés
      return unless session["follower_likes"]

      session["follower_likes"].each do |account_name, data|
        social_target = campagne.social_targets.find_by(kind: "account", name: account_name)
        next unless social_target

        # Mettre à jour les statistiques
        posts_liked = data["posts_liked"] || []
        total_likes = data["likes"] || 0

        social_target.update!(
          total_likes:,
          posts_liked:,
          last_activity: Time.current
        )
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
        raise ArgumentError, "Compte #{index}: targeted_accounts doit être un array"
      end

      return unless account["hashtags"].empty? && account["targeted_accounts"].empty?

      raise ArgumentError, "Compte #{index}: au moins un hashtag ou un compte cible doit être spécifié"

      validate_hashtags_structure(account["hashtags"], index)
      validate_targeted_accounts_structure(account["targeted_accounts"], index)
    end

    def self.validate_hashtags_structure(hashtags, account_index)
      hashtags.each_with_index do |hashtag, hashtag_index|
        if hashtag.is_a?(Hash)
          unless hashtag.key?("hashtag")
            raise ArgumentError, "Compte #{account_index}: hashtag #{hashtag_index}: champ 'hashtag' manquant"
          end

          if hashtag["hashtag"].blank?
            raise ArgumentError, "Compte #{account_index}: hashtag #{hashtag_index}: hashtag ne peut pas être vide"
          end
        elsif hashtag.is_a?(String)
          if hashtag.blank?
            raise ArgumentError, "Compte #{account_index}: hashtag #{hashtag_index}: hashtag ne peut pas être vide"
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
                  "Compte #{account_index}: targeted_account #{account_target_index}: champ 'account' manquant"
          end

          if account["account"].blank?
            raise ArgumentError,
                  "Compte #{account_index}: targeted_account #{account_target_index}: account ne peut pas être vide"
          end
        elsif account.is_a?(String)
          if account.blank?
            raise ArgumentError,
                  "Compte #{account_index}: targeted_account #{account_target_index}: account ne peut pas être vide"
          end
        else
          raise ArgumentError,
                "Compte #{account_index}: targeted_account #{account_target_index}: doit être un string ou un hash"
        end
      end
    end
  end
end
