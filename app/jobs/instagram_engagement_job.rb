# frozen_string_literal: true

class InstagramEngagementJob < ApplicationJob
  queue_as :default

  def perform(user_id, social_campagne_id)
    if user_id.blank? || social_campagne_id.blank?
      SocialCampagne.where(status: "active").each do |social_campagne|
        self.class.perform_later(social_campagne.user_id, social_campagne.id)
      end
      return
    end
    user = User.find(user_id)
    social_campagne = SocialCampagne.find(social_campagne_id)

    Instagram::EngagementService.call_from_user(
      user,
      user.instagram_username,
      user.instagram_password,
      social_campagne:
    )
  end
end
