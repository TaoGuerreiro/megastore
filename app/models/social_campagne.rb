class SocialCampagne < ApplicationRecord
  belongs_to :user
  has_many :social_targets, dependent: :destroy

  enum status: { active: "active", paused: "paused" }

  validates :status, presence: true
end
