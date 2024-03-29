# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    def show?
      user_id_queen_or_admin?
    end

    def edit?
      user_id_queen_or_admin?
    end

    def update?
      user_id_queen_or_admin?
    end
  end
end
