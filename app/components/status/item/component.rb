module Status
  module Item
    class Component < ViewComponent::Base
      def initialize(status:)
        @status = status
      end

      def render?
        @status.present?
      end

      def online?
        @status == :active
      end
    end
  end
end
