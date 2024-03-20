# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :store

  def endi_token
    store&.endi_token
  end
end
