# frozen_string_literal: true

module Filterable
  module Components
    class ShowTurboStreamComponent < ApplicationComponent
      def initialize(filters:, filterable_context:)
        super
        @filters = filters
        @filterable_context = filterable_context
      end

      def call
        helpers.turbo_stream.replace(model.filterable.turbo_frame_id) do
          render FiltersFormComponent.new(filters: filters, filterable_context: filterable_context)
        end
      end

      private

      attr_reader :filters, :filterable_context

      delegate :model, to: :filterable_context
    end
  end
end
