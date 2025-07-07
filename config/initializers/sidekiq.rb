require "sidekiq"
require "sidekiq-scheduler"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379" }

  # Configuration du scheduler pour les jobs récurrents
  config.on(:startup) do
    schedule_path = Rails.root.join("sidekiq_schedule.yml")
    if File.exist?(schedule_path)
      Sidekiq.schedule = YAML.load_file(schedule_path)
      puts "=== [Sidekiq] Schedule chargé depuis #{schedule_path} ==="
    else
      puts "=== [Sidekiq] Schedule introuvable à #{schedule_path} ==="
    end
    Sidekiq::Scheduler.reload_schedule!
  end

  # Configuration pour l'interface web du scheduler
  config.on(:startup) do
    Sidekiq::Scheduler.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] || "redis://localhost:6379" }
end
