# frozen_string_literal: true

class OrderPresenter < BasePresenter
  # border-red-500
  # border-gray-400
  # border-yellow-500
  # border-indigo-800
  # border-green-500
  # border-red-500

  STATUS_COLORS = {
    pending: { bg: "bg-gray-400", text: "text-white", raw: "-gray-400", exa: "#9CA3AF", colored_text: "text-content" },
    confirmed: { bg: "bg-yellow-500", text: "text-white", raw: "-yellow-500", exa: "#EAB308", colored_text: "text-yellow-500" },
    refunded: { bg: "bg-indigo-800", text: "text-white", raw: "-indigo-800", exa: "#3730A3", colored_text: "text-indigo-800" },
    paid: { bg: "bg-green-500", text: "text-white", raw: "-green-500", exa: "#22C55E", colored_text: "text-green-500" },
    sent: { bg: "bg-green-500", text: "text-white", raw: "-green-500", exa: "#22C55E", colored_text: "text-green-500" },
    canceled: { bg: "bg-red-500", text: "text-white", raw: "-red-500", exa: "#ff0000", colored_text: "text-red-500" }
  }.with_indifferent_access.freeze

  STATUS_ICON_CLASSES = {
    pending: "fa-ruler-triangle",
    refunded: "fa-file-invoice-dollar",
    confirmed: "fa-hourglass",
    paid: "fa-check",
    sent: "fa-check",
    canceled: "fa-xmark"
  }.with_indifferent_access.freeze

  def status_icon_class
    STATUS_ICON_CLASSES[__getobj__.status]
  end

  def status_text_color
    STATUS_COLORS[__getobj__.status][:colored_text] || "text-content"
  end

  def status_bg_color
    STATUS_COLORS[__getobj__.status][:bg] || "bg-gray-500"
  end

  def shipping_address
    h.content_tag :div, __getobj__.shipping_address, class: "text-left font-base "
  end

  def status
    h.content_tag :div, class: "flex items-center justify-between  px-2" do
      h.concat h.content_tag :div, h.t(__getobj__.status)
      h.concat h.content_tag :i, "",
                             class: "#{status_text_color} #{status_icon_class} fa-solid fa-fw animate-pulse ml-1"
    end
  end

  def id
    h.content_tag :div, __getobj__.id, class: "text-left font-bold"
  end

  def amount_cents
    h.content_tag :div, h.number_to_currency(__getobj__.amount, unit: "€"), class: "text-right px-3"
  end
end
