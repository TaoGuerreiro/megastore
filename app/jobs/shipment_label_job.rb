# frozen_string_literal: true

class ShipmentLabelJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    store = order.store

    log_operation("label_creation_started", order_id:)

    begin
      parcel = Shipments::Parcel.new(store, order:)
      response = parcel.create_label

      if order.shipping.method_carrier == "poste"
        parcel.attach_postale_label_to_order(response)
      else
        parcel.attach_to_order
      end

      log_operation("label_creation_success", order_id:)
    rescue StandardError => e
      log_operation("label_creation_failed", order_id:, error: e.message)
      order.shipping.update(api_error: e.to_s, status: "failed")
      raise e
    end
  end

  private

  def log_operation(operation, details = {})
    Rails.logger.info(
      "ShipmentLabelJob #{operation}",
      details.merge(job_id:)
    )
  end
end
