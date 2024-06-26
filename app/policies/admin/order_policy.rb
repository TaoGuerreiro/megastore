# frozen_string_literal: true

module Admin
  class OrderPolicy < ApplicationPolicy
    # See https://actionpolicy.evilmartians.io/#/writing_policies

    relation_scope do |relation|
      relation.includes(:order_items, :items).where(store: Current.store)
    end

    def index?
      queen_or_admin?
    end

    def show?
      queen_or_admin?
    end

    def destroy?
      queen_or_admin?
    end
  end
end
