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
    all_cards = CarouselCard.order(:position_x, :position_y).to_a
    column_count = 3
    balanced_columns = Array.new(column_count) { [] }

    # Distribute cards evenly across the columns
    all_cards.each_with_index do |card, index|
        column_index = index % column_count
        balanced_columns[column_index] << card
    end

    # Update the position_x and position_y for each card, starting indices at 1
    balanced_columns.each_with_index do |cards, x|
      cards.each_with_index do |card, y|
          card.update!(position_x: x + 1, position_y: y + 1)
      end
    end
  end
end
