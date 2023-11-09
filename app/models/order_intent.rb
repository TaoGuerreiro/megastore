class OrderIntent
  include ActiveModel::Model

  attr_accessor :email, :first_name, :last_name, :address, :phone, :shipping_method

  def initialize(attr = {})
    @email = attr[:email]
    @first_name = attr[:first_name]
    @last_name = attr[:last_name]
    @address = attr[:address]
    @phone = attr[:phone]
    @shipping_method = attr[:shipping_method]
  end

  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :address, presence: true
  validates :phone, presence: true
  validates :shipping_method, presence: true
end
