Rails.application.config.after_initialize do
  Dir[Rails.root.join("app/components/**/*.yml")].each do |file|
    I18n.load_path << file unless I18n.load_path.include?(file)
  end
end
