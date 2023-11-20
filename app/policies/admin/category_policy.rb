class Admin::CategoryPolicy < ApplicationPolicy

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
