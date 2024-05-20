# frozen_string_literal: true

module Buttons
  module Option
    class Component < ApplicationComponent
      attr_reader :label, :icon

      def initialize(label:, icon: nil)
        super
        @label = label
        @icon = icon
      end
    end
  end
end
