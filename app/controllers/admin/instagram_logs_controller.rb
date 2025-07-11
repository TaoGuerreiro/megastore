# frozen_string_literal: true

module Admin
  class InstagramLogsController < AdminController
    def index
      @logs = current_user.social_campagne&.campagne_logs&.order(created_at: :desc) || []
    end
  end
end
