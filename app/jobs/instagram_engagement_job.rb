# frozen_string_literal: true

class InstagramEngagementJob < ApplicationJob
  queue_as :default

  def perform(user_id, social_campagne_id)
    user = User.find(user_id)
    social_campagne = SocialCampagne.find(social_campagne_id)

    # Récupérer les SocialTargets de la campagne
    hashtags = social_campagne.social_targets.where(kind: "hashtag").map do |target|
      {
        "name" => target.name,
        "kind" => target.kind,
        "cursor" => target.cursor
      }
    end

    targeted_accounts = social_campagne.social_targets.where(kind: "account").map do |target|
      {
        "name" => target.name,
        "kind" => target.kind,
        "cursor" => target.cursor
      }
    end

    Instagram::EngagementService.call_from_user(
      user,
      user.instagram_username,
      user.instagram_password,
      social_campagne:
    )
  end
end
