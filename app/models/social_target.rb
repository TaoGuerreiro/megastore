# frozen_string_literal: true

class SocialTarget < ApplicationRecord
  belongs_to :social_campagne

  # Sérialisation JSON pour posts_liked
  serialize :posts_liked, JSON

  validates :name, presence: true
  validates :kind, presence: true, inclusion: { in: %w[hashtag account] }
  validates :social_campagne_id, presence: true
  validates :name,
            uniqueness: { scope: [:social_campagne_id, :kind], message: "déjà utilisé pour ce type et cette campagne" }

  # Validations pour les statistiques
  validates :total_likes, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Méthodes pour gérer les statistiques
  def add_liked_post(post_id)
    posts_liked << post_id unless posts_liked.include?(post_id)
    increment!(:total_likes)
    update!(last_activity: Time.current)
  end

  def reset_stats
    update!(
      total_likes: 0,
      posts_liked: [],
      last_activity: nil
    )
  end

  def has_liked_post?(post_id)
    posts_liked.include?(post_id)
  end
end
