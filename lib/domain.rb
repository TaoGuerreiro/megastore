# frozen_string_literal: true

class Domain
  def self.matches?(request)
    request.domain.in?(["chalky.fr", "lecheveublanc.fr", "ngrok.io", "unsafehxc.fr", "studioanemone.fr", "kenjosset.com"])
  end
end
