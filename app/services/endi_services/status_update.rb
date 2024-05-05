# frozen_string_literal: true

module EndiServices
  class StatusUpdate
    include ApplicationHelper

    def initialize(order, user)
      @order = order
      @user = user
    end

    def call
      return if @order.endi_id.nil?

      response = EndiServices::GetInvoice.new(@order, @user).call

      if response.code == 401
        EndiServices::ResetAuth.new(@user).call
        response = EndiServices::GetInvoice.new(@order, @user).call
      end

      @order.update(bill_ref: response["internal_number"]) if response["official_number"].blank?
      @order.update(endi_price_cents: (response["ht"] * 100).to_i)
      @order.update(billing_date: response["date"].to_date)

      if response["status_history"].any? { |hash| hash["status"] == "resulted" }
        @order.paid!(mail: true)
        @order.update(bill_ref: response["official_number"],
                      payment_date: response.dig("status_history", 0, "datetime").to_date)
      end
      case response.dig("status_history", 0, "status")
      when "resulted"
        @order.paid!(mail: true)
        @order.update(bill_ref: response["official_number"],
                      payment_date: response.dig("status_history", 0, "datetime").to_date)
      when "wait"
        @order.draft!
      when "valid"
        @order.update(bill_ref: response["official_number"])
        @order.billed! unless @order.already_sent? || @order.paid?
      else
        @order.update(bill_ref: response["official_number"] || response["internal_number"])
      end
    end
  end
end
