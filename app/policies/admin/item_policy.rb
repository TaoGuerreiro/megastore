class Admin::ItemPolicy < ApplicationPolicy

  relation_scope do |relation|
    # next relation if user.admin?
    relation.with_archived.where(store: Current.store)
  end

  def new?
    true
  end

  def create?
    true
  end

  def archive?
    user.id == record.store.admin_id
  end

  def unarchive?
    user.id == record.store.admin_id
  end

  def index?
    true
  end

  def edit?
    user.id == record.store.admin_id
  end

  def update?
    edit?
  end

  def destroy?
    (user.id == record.store.admin_id) && record.order_items.empty?
  end

  def remove_photo?
    user.id == record.store.admin_id
  end

  # #
  # def update?
  #   # here we can access our context and record
  #   user.admin? || (user.id == record.user_id)
  # end

  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping
  #
  # relation_scope do |relation|
  #   next relation if user.admin?
  #   relation.where(user: user)
  # end
end
