# frozen_string_literal: true

module Filterable
  extend ActiveSupport::Concern

  FILTERS_REGISTRY = {
    string: Filter::String,
    integer: Filter::Number,
    float: Filter::Number,
    decimal: Filter::Number,
    date: Filter::Date,
    datetime: Filter::Date,
    association: Filter::Association,
    boolean: Filter::Boolean
  }.with_indifferent_access.freeze

  def self.btn_classes
    'btn border !inline-block flex p-0 text-gray-700 border-gray-300 bg-white shadow-sm focus:ring-gray-500'
  end

  def self.btn_active_classes
    'bg-zinc-50 font-semibold'
  end

  class_methods do
    attr_reader :filterable

    def filterable(&block)
      if block
        @filterable = Base.new(self)
        @filterable.instance_exec(&block)
      else
        @filterable
      end
    end

    def filter(payload, base_relation: all)
      filters_payload = payload.fetch(:filters, [])
      conjonction = payload.fetch(:conjonction, :and)
      result = FilterSet.from_payload(self, filters_payload, conjonction, base_relation).execute

      sanitized_sort = payload[:sort]&.then do |sort|
        column_name, order = sort.to_h.entries.first
        { column_name => order } if valid_sort?(column_name, order)
      end

      sanitized_sort ? result.reorder(sanitized_sort) : result
    end

    private

    def valid_sort?(column_name, order)
      column_name.to_s.in?(column_names) && order.in?(%w[asc desc])
    end
  end
end
