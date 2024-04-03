# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :store, :endi_auth

  def endi_auth
    store&.endi_auth
  end
end
