
class Admin::OrderMailer < ApplicationMailer
  def payment_confirmation(order)
    @order = order
    mail to: @order.user.email, subject: "Confirmation de paiement"
  end
end
