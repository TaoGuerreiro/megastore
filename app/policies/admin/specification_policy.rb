class Admin::SpecificationPolicy < ApplicationPolicy

  relation_scope do |relation|
    # next relation if user.admin?
    relation.where(store: Current.store)
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    user.id == record.store.admin_id
  end

  def update?
    user.id == record.store.admin_id
  end

  def destroy?
    user.id == record.store.admin_id
  end

end
