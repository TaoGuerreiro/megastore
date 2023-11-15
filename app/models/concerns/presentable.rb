# frozen_string_literal: true

##
# == Presentable
#
# This module intend to make the use of {presenters}[https://nithinbekal.com/posts/rails-presenters/]
# as non-intrusive as possible.
# To use it, you need to first create a presenter class in the app/presenters folder.
# Then, include Presentable into the desired class to be presented.
# The presenter class name is inferred from the base class name ; however, if your presenter
# has a custom name, you can change this behavior. See +.presenter+
# Basic usage could be:
#
#   class OrderPresenter < BasePresenter
#     def human_checked_at
#       I18n.l __getobj__.checked_at, format: "%a, %d %B"
#     end
#   end
#
#   class Order
#     include Presentable
#
#     # [...]
#   end
#
#   Order.presenter # => OrderPresenter
#
#   order = Order.find(10) # => #<Order id: 10, checked_at: Wed, 13 Apr 2022 10:30:39.580874000 CEST +02:00>
#
#   order.presented.human_checked_at # => "mer, 13 avril"
#
# See BasePresenter for implementation details.
module Presentable
  extend ActiveSupport::Concern

  included do
    ##
    # Returns presented object, wrap with the class' presenter.
    def presented
      @presented ||= self.class.presenter.new(self)
    end

    ##
    # :singleton-method: presenter
    # Returns the presenter class. Can be overwritten if the
    # presenter's name can't be inferred  from the class' name
    #   class Order
    #     include Presentable
    #   end
    #
    #   Order.presenter # => OrderPresenter
    #
    # In this case, Order.presenter is defined as
    #   class Order
    #     def self.presenter
    #       OrderPresenter
    #     end
    #   end

    # :nodoc: .presenter definition
    class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
      def self.presenter = ::#{name}Presenter # => e.g: def self.presenter = OrderPresenter
    RUBY
  end
end
