# frozen_string_literal: true

module Filterable
  module Components
    class ViewFormComponent < ApplicationComponent
      def initialize(filterable_context:)
        super
        @filterable_context = filterable_context
      end

      private

      attr_reader :filterable_context

      delegate :views_owner, :model, to: :filterable_context

      def view_title_input_classes
        <<~TXT
          grow px-2 py-1 text-sm shadow-sm border-gray-300 rounded-md
          focus:ring-indigo-200 focus:border-indigo-200
          placeholder:italic placeholder:text-slate-400
        TXT
      end
    end
  end
end
