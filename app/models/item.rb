# app/models/item.rb
class Item < ApplicationRecord
  extend Enumerize
  attr_accessor :active

  # default_scope { where(status: :active) }

  belongs_to :store
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many_attached :photos

  STATUS = ["active", "archived", "offline"].freeze
  enumerize :status, in: STATUS, default: :active, predicates: true

  monetize :price_cents

  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true
  validates :stock, presence: true

  def self.with_archived
    unscoped.order(:status, :name)
  end

  def active?
    status == "active"
  end

  def archived?
    status == "archived"
  end

  def archive!
    update(status: :archived)
  end
end
