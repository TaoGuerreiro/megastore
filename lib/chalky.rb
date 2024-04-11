# frozen_string_literal: true

class Chalky
  def self.matches?(request)
    request.domain.in?(["chalky.fr", "localhost"])
  end
end
