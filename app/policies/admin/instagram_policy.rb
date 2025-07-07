# frozen_string_literal: true

module Admin
  class InstagramPolicy < ApplicationPolicy
    def show?
      queen_or_admin?
    end

    def update_engagement_config?
      queen_or_admin?
    end

    def launch_engagement?
      queen_or_admin?
    end

    def update_status?
      queen_or_admin?
    end

    def toggle_status?
      queen_or_admin?
    end
  end
end
