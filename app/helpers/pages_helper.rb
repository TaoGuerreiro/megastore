# frozen_string_literal: true

module PagesHelper
  def images_from_directory(folder)
    Dir.glob("app/assets/images/#{Current.store.slug}/#{folder}/*").map { |path| path.gsub("app/assets/images/", "") }
  end
end
