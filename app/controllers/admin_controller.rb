# frozen_string_literal: true


class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_subscription
  layout 'admin'

  private

  def check_subscription
    return if current_user.queen?
    return if params["controller"] == "admin/subscriptions" && params["action"] == "create"

    redirect_to new_admin_onboarding_path unless current_user.stores.first.active_subscription?
  end
end
