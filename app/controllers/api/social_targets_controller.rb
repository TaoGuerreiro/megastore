# frozen_string_literal: true

module Api
  class SocialTargetsController < ApplicationController
    skip_before_action :verify_authenticity_token
    protect_from_forgery with: :null_session

    before_action :authenticate_token
    before_action :set_social_campagne
    before_action :set_social_target, only: [:like, :update]

    def like
      post_id = params[:post_id]

      if post_id.blank?
        render json: { error: "post_id est requis" }, status: :bad_request
        return
      end

      if @social_target.add_liked_post(post_id)
        render json: {
          success: true,
          total_likes: @social_target.total_likes,
          posts_liked_count: @social_target.posts_liked.size,
          message: "Post liké avec succès"
        }
      else
        render json: { error: "Impossible de mettre à jour les statistiques" }, status: :unprocessable_entity
      end
    end

    def update
      if @social_target.update(social_target_params)
        render json: {
          success: true,
          message: "Social target mis à jour avec succès",
          cursor: @social_target.cursor
        }
      else
        render json: { error: "Impossible de mettre à jour le social target" }, status: :unprocessable_entity
      end
    end

    private

    def authenticate_token
      token = request.headers["Authorization"]&.split(" ")&.last
      expected_token = Rails.application.credentials[:social_campaign_token] || ENV.fetch("SOCIAL_CAMPAIGN_API_TOKEN",
                                                                                          nil)

      # Debug temporaire
      Rails.logger.debug { "Token reçu: #{token}" }
      Rails.logger.debug { "Token attendu: #{expected_token}" }
      Rails.logger.debug { "Token dans credentials: #{Rails.application.credentials[:social_campaign_token]}" }

      return if token && expected_token && token == expected_token

      render json: { error: "Token invalide", debug: { received: token, expected: expected_token } },
             status: :unauthorized
      nil
    end

    def set_social_campagne
      @social_campagne = SocialCampagne.find(params[:social_campagne_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Campagne non trouvée" }, status: :not_found
    end

    def set_social_target
      @social_target = @social_campagne.social_targets.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Social target non trouvé" }, status: :not_found
    end

    def social_target_params
      params.permit(:cursor)
    end
  end
end
