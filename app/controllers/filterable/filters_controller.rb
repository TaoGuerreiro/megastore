# frozen_string_literal: true

module Filterable
  class FiltersController < ApplicationController
    def show
      model = filterable_context.model
      @filters = Filter.parse(model, filterable_params.fetch(:filters, []))

      column_update_trigger if trigger?("column_update")

      respond_to do |format|
        format.turbo_stream do
          render Components::ShowTurboStreamComponent.new(filters: @filters, filterable_context:)
        end
      end
    end

    def create
      model = filterable_context.model
      filters = Filter.parse(model, filterable_params.fetch(:filters, []))
      filters << model.filterable.filter_placeholder

      render html: render_to_string(
        Components::FiltersFormComponent.new(filters:, filterable_context:)
      )
    end

    private

    def filterable_context
      @filterable_context ||= Context.new(
        params[:filterable_model_name].constantize,
        filterable_params[:context_name],
        URI.parse(filterable_params[:submit_path]).path,
        current_user
      )
    end

    def trigger?(trigger_name)
      params[:trigger].present? && params[:trigger].include?(trigger_name)
    end

    def column_update_trigger
      match_data = params[:trigger].match(/\Acolumn_update_(?<index>\d+)\z/)
      column_index = match_data[:index].to_i
      updated_filter = @filters[column_index]

      updated_filter.set_to_default_operator!
    end
  end
end
