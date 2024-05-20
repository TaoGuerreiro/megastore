# frozen_string_literal: true

module EndiServices
  class StatusUpdate < EndiService
    include ApplicationHelper

    def initialize(order)
      super
      @order = order
    end

    def call
      return if @order.endi_id.nil?

      response = EndiServices::GetInvoice.new(@order).call
      handle_response(response)
    end

    private

    def handle_response(response)
      if response.code == 401
        handle_unauthorized
      else
        update_order_from_response(response)
        update_order_status(response)
      end
    end

    def handle_unauthorized
      EndiServices::ResetAuth.new.call
      response = EndiServices::GetInvoice.new(@order).call
      handle_response(response)
    end

    def update_order_from_response(response)
      @order.update(
        bill_ref: response["internal_number"].presence || response["official_number"],
        endi_price_cents: (response["ht"] * 100).to_i,
        billing_date: response["date"].to_date
      )
    end

    def update_order_status(response)
      status = response.dig("status_history", 0, "status")
      case status
      when "resulted"
        update_resulted_status(response)
      when "wait"
        @order.draft!
      when "valid"
        update_valid_status
      end
    end

    def update_resulted_status(response)
      @order.paid!(mail: true)
      @order.update(payment_date: response.dig("status_history", 0, "datetime").to_date)
    end

    def update_valid_status
      return if @order.already_sent? || @order.paid?

      @order.billed!
    end
  end
end
