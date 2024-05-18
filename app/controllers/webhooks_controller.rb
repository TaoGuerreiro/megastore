# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event = Event.create(data: request.body.read, source: request.path.split("/").last)
    if Rails.env.test?
      EventJob.perform_now(event)
    else
      EventJob.perform_later(event)
    end
    render json: { status: "ok" }
  end
end
