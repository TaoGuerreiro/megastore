# frozen_string_literal: true

class Domain
  def self.matches?(request)
    return true if Rails.env.test?

    request.domain.in?(["localhost", "chalky.fr", "ngrok.io", "unsafehxc.fr", "studioanemone.fr",
                        "kenjosset.com", "ttt-editions.fr"])
  end
end
