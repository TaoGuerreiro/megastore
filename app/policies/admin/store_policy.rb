class Admin::StorePolicy < ApplicationPolicy
  def show?
    user.id == record.admin_id
  end

  def edit?
    user.id == record.admin_id
  end

  def update?
    user.id == record.admin_id
  end
end
