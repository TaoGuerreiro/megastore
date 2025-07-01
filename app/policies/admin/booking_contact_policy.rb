# frozen_string_literal: true

module Admin
  class BookingContactPolicy < ApplicationPolicy
    def new?
      queen_or_admin?
    end

    def create?
      queen_or_admin?
    end

    def edit?
      queen_or_admin?
    end

    def update?
      queen_or_admin?
    end

    def destroy?
      queen_or_admin?
    end
  end
end
