module List
  module Link
    class Component < ViewComponent::Base
      attr_accessor :icon, :label, :path

      def initialize(icon: nil, label:, path:)
        @icon = icon
        @label = label
        @path = path
      end
    end
  end
end
