# frozen_string_literal: true

class User < ApplicationRecord
  extend Enumerize
  delegate :name, to: :store, prefix: true, allow_nil: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  enumerize :role, in: %i[admin user queen], default: :user, predicates: true

  has_one :store, foreign_key: :admin_id, inverse_of: :admin, dependent: :nullify
  validates :first_name, :last_name, :phone, presence: true
  has_one_attached :avatar
  has_one :social_campagne, dependent: :destroy

  has_many :social_targets, dependent: :destroy

  accepts_nested_attributes_for :store

  # Champs Instagram
  validates :instagram_username, length: { maximum: 255 }, allow_blank: true
  validates :instagram_password, length: { maximum: 255 }, allow_blank: true
  validates :instagram_user_id, length: { maximum: 255 }, allow_blank: true

  def is_current_store_admin?
    self&.store&.admin == self || self&.queen?
  end

  def full_name
    "#{first_name&.capitalize} #{last_name&.upcase}".strip.presence || email
  end

  def initials
    "#{first_name&.first}#{last_name&.first}".upcase
  end

  def stripe_customer_id
    return customer_id if customer_id?

    customer = Stripe::Customer.create(email:)
    update!(customer_id: customer.id)
    customer.id
  end

  def self.queen
    find_by(email: "hello@chalky.fr")
  end
end
