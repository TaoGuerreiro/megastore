class CarouselCard < ApplicationRecord
  has_many_attached :images
  has_one_attached :cover

  after_create_commit :update_position

  validates :title, presence: true
  validates :cover, presence: true

  def all_images
    image_attachments = images.attached? ? images.blobs.to_a : []
    cover_attachments = cover.attached? ? [cover.blob] : []

    image_attachments + cover_attachments
  end

  def update_position
    max_y = CarouselCard.all.max_by(&:position_y).position_y
    card.update!(position_x: 3, position_y: max_y + 1)
  end
end