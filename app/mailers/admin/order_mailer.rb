
class Admin::OrderMailer < ApplicationMailer
  def payment_confirmation(order)
    @order = order
    mail to: @order.user.email, subject: "Confirmation de paiement"
  end

  def new_order(order)
    @order = order
    @store = @order.items.first.store
    email = @store.admin.email
    mail to: email, subject: "Nouvelle commande"
  end
end
