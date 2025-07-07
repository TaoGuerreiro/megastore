class MigrateSocialTargetsToCampagnes < ActiveRecord::Migration[7.0]
  def up
    User.find_each do |user|
      campagne = SocialCampagne.create!(user: user, status: "active", name: "Campagne principale")
      user.social_targets.update_all(social_campagne_id: campagne.id)
    end
  end

  def down
    SocialTarget.update_all(social_campagne_id: nil)
    SocialCampagne.delete_all
  end
end
