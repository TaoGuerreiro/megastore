# frozen_string_literal: true

module Admin
  class CategoryPolicy < ApplicationPolicy
    relation_scope do |relation|
      relation.with_archived.where(store: Current.store)
    end

    def new?
      queen_or_admin?
    end

    def create?
      queen_or_admin?
    end

    def edit?
      queen_or_store_record?
    end

    def update?
      queen_or_store_record?
    end

    def destroy?
      queen_or_store_record?
    end
  end
end
