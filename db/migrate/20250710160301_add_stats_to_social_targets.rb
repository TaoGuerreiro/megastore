class AddStatsToSocialTargets < ActiveRecord::Migration[7.0]
  def change
    add_column :social_targets, :total_likes, :integer, default: 0, null: false
    add_column :social_targets, :posts_liked, :text, default: "[]", null: false
    add_column :social_targets, :last_activity, :datetime
  end
end
