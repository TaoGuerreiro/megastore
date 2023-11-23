class Domain
  def self.matches? request
    request.domain == 'localhost' || request.domain == 'lecheveublanc.fr' || request.domain == 'ngrok.io' || request.domain == 'unsafehxc.fr' || request.domain == 'studioanemone.fr'
  end
end
