class Admin::UserPolicy < ApplicationPolicy
  def show?
    user.id == record.id
  end

  def edit?
    user.id == record.id
  end

  def update?
    user.id == record.id
  end
end
