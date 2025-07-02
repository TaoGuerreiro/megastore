# frozen_string_literal: true

module Admin
  class BookingPolicy < ApplicationPolicy
    def index?
      queen_or_admin?
    end

    def new?
      queen_or_admin?
    end

    def create?
      queen_or_admin?
    end

    def show?
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

    def add_step?
      queen_or_admin?
    end

    def reset_steps?
      queen_or_admin?
    end
  end
end
