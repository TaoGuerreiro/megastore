class InstagramUserIdJob
  include Sidekiq::Job

  def perform(model_name, record_id, ig_username, ig_password, ig_handle)
    model = model_name.constantize
    record = model.find_by(id: record_id)
    return unless record && ig_handle.present?

    begin
      user_id = Instagram::FetchUserId.call(username: ig_username, password: ig_password, handle: ig_handle)
      record.update_column(:instagram_user_id, user_id)
    rescue StandardError => e
      Rails.logger.error("InstagramUserIdJob: Erreur récupération user_id Instagram: #{e}")
    end
  end
end
