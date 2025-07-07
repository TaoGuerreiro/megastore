class AddSocialCampagneIdToSocialTargets < ActiveRecord::Migration[7.0]
  def change
    add_reference :social_targets, :social_campagne, foreign_key: true
  end
end
