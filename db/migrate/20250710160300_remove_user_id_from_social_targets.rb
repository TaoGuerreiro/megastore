class RemoveUserIdFromSocialTargets < ActiveRecord::Migration[7.0]
  def change
    remove_reference :social_targets, :user, foreign_key: true
  end
end
