# frozen_string_literal: true

class OrderIntent
  include ActiveModel::Model

  attr_accessor :email, :first_name, :last_name, :address, :postal_code, :city, :country,
                :phone, :shipping_method, :service_point, :items_price, :shipping_price,
                :need_point, :weight, :street_number, :fees_price, :library

  def initialize(attr = {})
    super
    @need_point = @need_point == true
  end

  with_options on: :step_one do
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :address, presence: true
    validates :phone, presence: true
    validates :country, presence: true
    validates :postal_code, presence: true
    validates :city, presence: true
    validates :need_point, inclusion: { in: [false, "false"] }
  end

  with_options on: :step_two do
    validates :shipping_method, presence: true
    validates :need_point, inclusion: { in: [true, "true"] }
  end

  with_options on: :finalize_order do
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :address, presence: true
    validates :phone, presence: true
    validates :country, presence: true
    validates :postal_code, presence: true
    validates :city, presence: true
    validates :shipping_method, presence: true
    validates :items_price, presence: true
    validates :shipping_price, presence: true
    validates :service_point, presence: true, if: :need_point?
  end

  def total_price_cents = (total_price * 100).to_i
  def need_point? = need_point == true
  def full_address = "#{address}, #{postal_code} #{city}, #{country}"
  def address_with_number = "#{street_number} #{address}"
  def full_name = "#{first_name} #{last_name}"
  def address_first_line = split_address[0]
  def address_second_line = split_address[1]

  def completed?
    (need_point? && service_point.present?) ||
      (!need_point? && shipping_method.present?)
  end

  def total_price
    return 0 if items_price.nil? || shipping_price.nil? || fees_price.nil?

    items_price.to_f + shipping_price.to_f + fees_price.to_f
  end

  def shipping_and_fees_price
    return 0 if shipping_price.nil? || fees_price.nil?

    shipping_price.to_f + fees_price.to_f
  end

  private

  def split_address
    return [address, ""] if address.size <= 25

    splitted_address = address.split
    half = (splitted_address.size / 2.0).ceil
    address_parts = splitted_address.each_slice(half).to_a

    [address_parts[0].join(" "), address_parts[1]&.join(" ")]
  end
end
