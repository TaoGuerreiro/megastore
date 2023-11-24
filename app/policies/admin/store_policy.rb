class Admin::StorePolicy < ApplicationPolicy
  def show?
    user.queen? || user.id == record.admin_id
  end

  def edit?
    user.queen? || user.id == record.admin_id
  end

  def update?
    user.queen? || user.id == record.admin_id
  end
end
