module Ttt
  module Button
    class Component < ViewComponent::Base
      attr_reader :path, :text

      renders_many :sub_links, "Ttt::Button::SubLink::Component"

      def initialize(path:, text:)
        @path = path
        @text = text
      end
    end
  end
end
