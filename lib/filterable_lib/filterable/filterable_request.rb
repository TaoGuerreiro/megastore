# frozen_string_literal: true

module Filterable
  module FilterableRequest
    extend ActiveSupport::Concern

    def filterable(model, base_relation = model.all)
      return base_relation if params[:filterable].blank?

      model.filter(filterable_params, base_relation:)
    end

    def filterable_params
      return {} if params[:filterable].blank?

      params.require(:filterable).permit(
        :conjonction,
        :submit_path,
        :selected_view_id,
        :context_name,
        sort: {},
        filters: %i[column_name operator value]
      )
    end

    def filterable_context_name
      "#{controller_path}##{action_name}".freeze
    end

    included do
      helper_method :filterable_params, :filterable_context_name
    end
  end
end
