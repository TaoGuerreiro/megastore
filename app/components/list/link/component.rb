# frozen_string_literal: true

module List
  module Link
    class Component < ViewComponent::Base
      attr_accessor :icon, :label, :path, :options

      def initialize(label:, path:, icon: nil, options: {})
        super
        @icon = icon
        @label = label
        @path = path
        @options = options
      end

      def options_with_classes
        @options[:class] = <<-TXT.squish!
          flex items-center p-2 text-sm font-semibold leading-6
          rounded-md text-contrast hover:text-primary hover:bg-light group gap-x-3
        TXT
        @options
      end
    end
  end
end
