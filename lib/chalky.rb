# frozen_string_literal: true

class Chalky
  def self.matches?(request)
    request.domain == "chalky.fr"
  end
end
