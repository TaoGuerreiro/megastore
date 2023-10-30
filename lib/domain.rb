class Domain
  def self.matches? request
    request.domain == 'localhost' || request.domain == 'ngrock.io'
  end
end
