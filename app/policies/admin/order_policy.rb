class Admin::OrderPolicy < ApplicationPolicy
  # See https://actionpolicy.evilmartians.io/#/writing_policies
  #

  relation_scope do |relation|
    # next relation if user.admin?
    relation.includes(:order_items, :items).where(items: {store: Current.store})
  end

  def index?
    true
  end

  def show?
    user.is == record.store.admin_id
  end
  #
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
