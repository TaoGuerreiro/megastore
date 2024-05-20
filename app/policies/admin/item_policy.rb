# frozen_string_literal: true

module Admin
  class ItemPolicy < ApplicationPolicy
    relation_scope do |relation|
      relation.with_archived.where(store: Current.store)
    end

    def index?
      queen_or_admin?
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
      edit?
    end

    def destroy?
      queen_or_store_record? && record.order_items.empty?
    end
  end
end
