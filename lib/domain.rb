class Domain
  def self.matches? request
    puts request
    request.domain == 'localhost' || request.domain == 'lecheveublanc.fr'
  end
end
