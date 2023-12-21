class CheckoutPolicy < ApplicationPolicy
  def show?
    details[:reason] = "Boutique en vacances !"
    !Current.store.holiday?
  end
end
