class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event = Event.create(data: request.body.read, source: request.path.split("/").last)
    EventJob.perform_later(event)
    render json: { status: 'ok' }
  end
end
