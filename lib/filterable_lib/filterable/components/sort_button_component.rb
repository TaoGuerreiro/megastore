# frozen_string_literal: true

module Filterable
  module Components
    class SortButtonComponent < ApplicationComponent
      renders_one :inner_content

      def initialize(model:, column:)
        super
        @model = model
        @column = column
      end

      def call
        return inner_content unless column.to_s.in?(model.column_names)

        form_id = model.filterable.form_id
        icon_fa_class = filterable_sort_icon(column)
        content_tag(:div, nil, {
                      class: "h-full cursor-pointer flex justify-between",
                      data: {
                        controller: "filterable-sort",
                        filterable_sort_form_id_value: form_id,
                        filterable_sort_column_name_value: column,
                        action: "click->filterable-sort#sortColumn"
                      }
                    }) do
          concat inner_content
          concat content_tag(:i, nil, class: "ml-2 fas fa-fw #{icon_fa_class}")
        end
      end

      private

      attr_reader :model, :column

      delegate :filterable_params, to: :helpers

      def filterable_sort_icon(column)
        current_sort = filterable_params[:sort]
        column_name, order = current_sort.to_h.entries.first if current_sort
        return "fa-sort" unless current_sort && column_name == column.to_s

        order == "asc" ? "fa-sort-down" : "fa-sort-up"
      end
    end
  end
end
