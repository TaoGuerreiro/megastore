class SocialTarget < ApplicationRecord
  belongs_to :social_campagne

  validates :name, presence: true
  validates :kind, presence: true, inclusion: { in: %w[hashtag account] }
  validates :social_campagne_id, presence: true
  validates :name,
            uniqueness: { scope: [:social_campagne_id, :kind], message: "déjà utilisé pour ce type et cette campagne" }
end
