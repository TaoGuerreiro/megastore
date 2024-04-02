# frozen_string_literal: true

class User < ApplicationRecord
  extend Enumerize
  delegate :name, to: :store, prefix: true, allow_nil: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  enumerize :role, in: %i[admin user queen], default: :user, predicates: true

  has_one :store, foreign_key: :admin_id
  validates :first_name, :last_name, :phone, presence: true
  has_one_attached :avatar

  accepts_nested_attributes_for :store

  def full_name
    "#{first_name&.capitalize} #{last_name&.upcase}".strip.presence || email
  end

  def initials
    "#{first_name&.first}#{last_name&.first}".upcase
  end

  def stripe_customer_id
    return customer_id if customer_id?

    customer = Stripe::Customer.create(email: email)
    update!(customer_id: customer.id)
    customer.id
  end
end
