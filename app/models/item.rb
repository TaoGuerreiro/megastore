# frozen_string_literal: true

# app/models/item.rb
class Item < ApplicationRecord
  include Filterable
  extend Enumerize
  include PgSearch::Model

  attr_accessor :active

  belongs_to :store
  belongs_to :category
  has_many :item_specifications, dependent: :destroy
  has_many :specifications, through: :item_specifications
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many_attached :photos

  STATUSES = %w[active archived offline].freeze
  enumerize :status, in: STATUSES, default: :active, predicates: true

  monetize :price_cents

  filterable do
    columns :name
    columns :description
    columns :price_cents
    columns :stock
    association :category, label_method: :name
  end

  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true
  validates :stock, presence: true
  validates :weight, presence: true

  scope :active, -> { where(status: :active) }
  scope :archived, -> { where(status: :archived) }
  scope :offline, -> { where(status: :offline) }

  pg_search_scope :search_by_name_and_description,
                  against: %i[name description],
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.with_archived
    unscoped.order(:status, :name)
  end

  def soldout?
    stock.zero?
  end

  def active?
    status == 'active'
  end

  def archived?
    status == 'archived'
  end

  def archive!
    update(status: :archived)
  end

  def destroyabled?
    order_items.empty?
  end
end
