# frozen_string_literal: true

module Filterable
  module Components
    class WrapperComponent < ApplicationComponent
      renders_one :filters_form, lambda {
        FiltersFormComponent.new(filters: filters, filterable_context: filterable_context)
      }

      def initialize(filters:, filterable_context:)
        super
        @filters = filters
        @filterable_context = filterable_context
      end

      private

      attr_reader :filters, :model, :submit_path, :filterable_context, :views_owner

      delegate :filterable_params, :filterable_active_filters?, to: :helpers
      delegate :model, :submit_path, :views_owner, to: :filterable_context

      def can_use_views?
        views_owner.present?
      end

      def label_text
        return selected_view.title if selected_view
        return I18n.t("filterable.filter") unless filterable_active_filters?

        I18n.t("filterable.active_filters", count: filterable_params[:filters].length)
      end

      def views
        @views ||= View.for_context(filterable_context).order(:title)
      end

      def selected_view
        @selected_view ||= views.find { |view| view.id == selected_view_id }
      end

      def selected_view_id
        filterable_params[:selected_view_id]&.to_i
      end

      def wrapper_classes
        ["h-full", Filterable.btn_classes]
      end

      def filters_btn_classes
        [
          "px-3 py-2 cursor-pointer rounded-l-md \
          max-w-[16rem] whitespace-nowrap overflow-hidden text-ellipsis \
          hover:bg-gray-50",
          ("rounded-r-md" unless can_use_views? && views.present?),
          (Filterable.btn_active_classes if filterable_active_filters?)
        ]
      end

      def views_btn_classes
        [
          <<~TXT,
            border-l px-2 inline-flex w-full justify-center items-center h-full cursor-pointer
            rounded-r-md
            hover:bg-gray-50
          TXT
          (Filterable.btn_active_classes if filterable_active_filters?)
        ]
      end
    end
  end
end
