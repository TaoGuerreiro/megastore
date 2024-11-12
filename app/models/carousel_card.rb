class CarouselCard < ApplicationRecord
  has_many_attached :images
  has_one_attached :cover

  before_validation :update_position, on: :create

  validates :title, presence: true
  validates :cover, presence: true
  validates :position_x, presence: true
  validates :position_y, presence: true

  def all_images
    image_attachments = images.attached? ? images.blobs.to_a : []
    cover_attachments = cover.attached? ? [cover.blob] : []

    image_attachments + cover_attachments
  end

  def update_position
    CarouselCard.where(position_x: 1).order(:position_y).each_with_index do |card, index|
      card.update!(position_x: 1, position_y: index + 1)
    end
    assign_attributes(position_x: 1, position_y: 0)
  end
end
