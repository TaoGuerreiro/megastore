class Admin::SpecificationPolicy < ApplicationPolicy

  relation_scope do |relation|
    relation.where(store: Current.store)
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
