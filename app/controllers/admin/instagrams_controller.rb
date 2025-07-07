# frozen_string_literal: true

module Admin
  class InstagramsController < AdminController
    before_action :authorize_instagram

    def show
      @campagne = current_user.social_campagne
      @hashtags = @campagne&.social_targets&.where(kind: "hashtag")&.pluck(:name) || []
      @targeted_accounts = @campagne&.social_targets&.where(kind: "account")&.pluck(:name) || []
      @instagram_configured = current_user.instagram_username.present? && current_user.instagram_password.present?
    end

    def update_engagement_config
      hashtags = params[:hashtags].to_s.split(",").map(&:strip).reject(&:blank?)
      targeted_accounts = params[:targeted_accounts].to_s.split(",").map(&:strip).reject(&:blank?)

      campagne = current_user.social_campagne || current_user.create_social_campagne!(status: "active",
                                                                                      name: "Campagne principale")

      # Hashtags
      existing_hashtags = campagne.social_targets.where(kind: "hashtag").pluck(:name)
      (hashtags - existing_hashtags).each { |h| campagne.social_targets.create!(name: h, kind: "hashtag") }
      (existing_hashtags - hashtags).each { |h| campagne.social_targets.where(kind: "hashtag", name: h).destroy_all }

      # Comptes ciblés
      existing_accounts = campagne.social_targets.where(kind: "account").pluck(:name)
      (targeted_accounts - existing_accounts).each { |a| campagne.social_targets.create!(name: a, kind: "account") }
      (existing_accounts - targeted_accounts).each do |a|
        campagne.social_targets.where(kind: "account", name: a).destroy_all
      end

      redirect_to admin_instagram_path, notice: t(".success")
    rescue StandardError => e
      redirect_to admin_instagram_path, alert: "#{t('.error')}: #{e.message}"
    end

    def launch_engagement
      unless current_user.instagram_username.present? && current_user.instagram_password.present?
        redirect_to admin_instagram_path, alert: t(".no_credentials")
        return
      end

      campagne = current_user.social_campagne
      unless campagne
        redirect_to admin_instagram_path, alert: t(".no_campaign")
        return
      end

      hashtags = campagne.social_targets.where(kind: "hashtag")
      targeted_accounts = campagne.social_targets.where(kind: "account")

      if hashtags.empty? && targeted_accounts.empty?
        redirect_to admin_instagram_path, alert: t(".no_targets")
        return
      end

      InstagramEngagementJob.perform_later(current_user.id, campagne.id)
      redirect_to admin_instagram_path, notice: t(".success_background")
    end

    def toggle_status
      campagne = current_user.social_campagne
      if campagne.nil?
        redirect_to admin_instagram_path, alert: t(".no_campaign")
        return
      end

      if campagne.active?
        campagne.update(status: "paused")
        notice = t(".status_paused")
      else
        campagne.update(status: "active")
        # Lancer le job d'engagement uniquement si on passe à actif
        InstagramEngagementJob.perform_later(current_user.id, campagne.id)
        notice = t(".status_activated_and_launched")
      end
      redirect_to admin_instagram_path, notice:
    end

    private

    def authorize_instagram
      authorize! :instagram
    end
  end
end
