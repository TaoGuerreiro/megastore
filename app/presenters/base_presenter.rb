# frozen_string_literal: true

require "delegate"

##
# == Presenter
# See Presentable in app/models/concerns/presentable.rb for usage with models.
#
# A Presenter is intended to wrap all code logic about presentation of an object,
# particulary in context of HTML views. For exemple if you want a formatted date attribute
# or an HTML based on an attribute value.
# See {this link}[https://nithinbekal.com/posts/rails-presenters/] for more about presenter concept.
# This is a simple implementation using SimpleDelegator.😏
# A presenter is instantiated with new by providing an instance of class to be presented.
# All unkown method for the presenter will be forwaded to the wrapped instance
#
#   class OrderPresenter < BasePresenter
#   end
#
#   order = Order.find(10) # => #<Order id: 10, checked_at: Wed, 13 Apr 2022 10:30:39.580874000 CEST +02:00>
#
#   presented_order = OrderPresenter.new(order)
#   presented_order.class # => OrderPresenter
#
#   presented_order.id # => 10 # no NoMethodError
#
# if you have a collection instead, use wrap:
#
#   presented_orders = OrderPresenter.wrap(Order.where.not(checked_at: nil)) # => [#<Order 0x0...>, #<Order0x1 ...>]
#   presented_orders.first.class # => OrderPresenter
#
# Inside presenter methods definition, if you want to use methods from the wrapped object,
# make it explicit by using the __getobj__ method. It is not mandatory but prefered style and
# a bit more performant (without it, it relies on method_missing error catching).
#
#   class OrderPresenter < BasePresenter
#     def human_checked_at
#       I18n.l __getobj__.checked_at, format: "%a, %d %B"
#     end
#   end
#
#   presented_order.human_checked_at # => "mer, 13 avril"
#
# To use view helper, either use the h method
#   class ProjectPresenter < BasePresenter
#     def title
#       h.content_tag(:h1, __getobj__.name)
#     end
#   end
#
# or url_h for urls and paths
#
#   class ProjectPresenter < BasePresenter
#     def name_with_link
#       h.link_to __getobj__.name, url_h.project_path(__getobj__)
#     end
#   end
# == For actual usage, please refer to Presentable concern.
class BasePresenter < SimpleDelegator
  NoViewContextError = Class.new(StandardError)

  ##
  # Wrap each instance within array with a presenter
  #
  #   presented_orders = OrderPresenter.wrap(Order.where.not(checked_at: nil)) # => [#<Order 0x0...>, #<Order0x1 ...>]
  #   presented_orders.first.class # => OrderPresenter
  def self.wrap(models)
    models.map { |model| new(model) }
  end

  ##
  # All views helpers but url_helpers
  def h
    ApplicationController.helpers
  end

  ##
  # All url_helpers
  def url_h
    Rails.application.routes.url_helpers
  end
end
