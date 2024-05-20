# frozen_string_literal: true

module Filterable
  module Components
    class FiltersFormComponent < ApplicationComponent
      renders_one :view_form, -> { ViewFormComponent.new(filterable_context:) }

      def initialize(filters:, filterable_context:)
        super
        @filters = filters
        @filterable_context = filterable_context
      end

      private

      attr_reader :filters, :filterable_context

      delegate :filterable_params, to: :helpers
      delegate :filterable, :submit_path, to: :filterable_context

      def current_sort_input(form)
        return unless (current_sort = filterable_params[:sort])

        column_name, order = current_sort.to_h.entries.first
        form.hidden_field "filterable[sort][#{column_name}]",
                          value: order,
                          data: { column_name: },
                          id: "filterable_sort"
      end

      def filterable_input_classes
        <<-TXT.squish!
          w-full min-w-fit block shadow-sm border-gray-300 rounded-md
          focus:ring-primary-500 focus:border-primary-500
          sm:text-sm
        TXT
      end

      def operators_for_select(filter)
        filter.operators_options.map do |(label, operator)|
          needs_input = filter.class.operator_needs_input?(operator)
          [label, operator, { "data-needs-input": needs_input }]
        end
      end

      def filterable_value_input(form, filter, index) # rubocop:disable Metrics/MethodLength
        input_name = "filterable[filters][][value]"
        input_options = { class: filterable_input_classes, data: { value_input_index: index } }
        input_options.merge!(style: "display: none;", disabled: true) unless filter.needs_input?

        if filter.type.in?(%i[date datetime])
          input_options[:value] = filter.value&.to_date
          form.date_field input_name, input_options
        elsif filter.needs_select_input?
          input_options[:class] = [filterable_input_classes, "cursor-pointer"]
          form.select input_name, filter.select_options, { selected: filter.value }, input_options
        else
          input_options[:value] = filter.value
          form.text_field input_name, input_options
        end
      end
    end
  end
end
