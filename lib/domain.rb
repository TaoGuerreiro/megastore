class Domain
  def self.matches? request
    puts "*" * 200
    puts request.domain
    puts "*" * 200
    request.domain == 'localhost' || request.domain == 'lecheveublanc.fr' || request.domain == 'ngrok.io' || request.domain == 'unsafehxc.fr'
  end
end
