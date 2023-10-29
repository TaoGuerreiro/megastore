class Domain
  def self.matches? request
    request.domain == 'localhost'
  end
end
