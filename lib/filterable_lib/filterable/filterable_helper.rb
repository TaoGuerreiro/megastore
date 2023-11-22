# frozen_string_literal: true

module Filterable
  module FilterableHelper
    def filterable_active_filters?
      params[:filterable].present? && filterable_params[:filters].present?
    end

    def filterable_form_for(model)
      filters =
        if filterable_active_filters?
          Filterable::Filter.parse(model, filterable_params.fetch(:filters, []))
        else
          []
        end

      filterable_context = Context.new(model, filterable_context_name, request.path, current_user)
      render Components::WrapperComponent.new(
        filters: filters,
        filterable_context: filterable_context
      )
    end

    def filterable_sort_button(model, column, &block)
      render Components::SortButtonComponent.new(model: model, column: column) do |c|
        c.with_inner_content(&block)
      end
    end
  end
end
