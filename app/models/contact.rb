# frozen_string_literal: true

class Contact
  include ActiveModel::Model

  attr_accessor :email, :full_name, :nickname, :content

  def initialize(attr = {})
    @email = attr[:email]
    @full_name = attr[:full_name]
    @content = attr[:content]
  end

  validates :email, presence: true
  validates :content, presence: true
  validates :full_name, presence: true
end
