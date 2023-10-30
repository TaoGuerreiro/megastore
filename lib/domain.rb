class Domain
  def self.matches? request
    request.domain == 'localhost' || request.domain == 'lecheveublanc.fr'
  end
end
