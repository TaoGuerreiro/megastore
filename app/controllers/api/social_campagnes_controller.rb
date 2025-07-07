# frozen_string_literal: true

module Api
  class SocialCampagnesController < ApplicationController
    skip_before_action :verify_authenticity_token
    protect_from_forgery with: :null_session

    before_action :authenticate_token
    before_action :set_social_campagne, only: [:status]

    def status
      if request.patch?
        # Mise à jour du statut
        if @social_campagne.update(status: params[:status])
          render json: { status: @social_campagne.status, message: "Statut mis à jour avec succès" }
        else
          render json: { error: "Impossible de mettre à jour le statut" }, status: :unprocessable_entity
        end
      else
        # Lecture du statut
        render json: { status: @social_campagne.status }
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
      @social_campagne = SocialCampagne.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Campagne non trouvée" }, status: :not_found
    end
  end
end
