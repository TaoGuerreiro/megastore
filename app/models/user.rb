class User < ApplicationRecord
  include Enumerize

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enumerize :role, in: %i[admin user], default: :user, predicates: true

  has_many :stores, foreign_key: :admin_id
  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name&.capitalize} #{last_name&.upcase}".strip.presence || email
  end
end
