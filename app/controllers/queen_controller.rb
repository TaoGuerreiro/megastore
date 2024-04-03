# frozen_string_literal: true

class QueenController < ApplicationController
  before_action :authenticate_user!
  layout "queen"
end
