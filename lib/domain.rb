class Domain
  def self.matches? request
    puts request.domain
    request.domain == 'localhost' || request.domain == 'ngrok.io'
  end
end
