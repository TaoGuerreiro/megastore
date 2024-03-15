# frozen_string_literal: true

class User < ApplicationRecord
  extend Enumerize

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enumerize :role, in: %i[admin user queen], default: :user, predicates: true

  has_many :stores, foreign_key: :admin_id
  validates :first_name, :last_name, presence: true
  has_one_attached :avatar

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
