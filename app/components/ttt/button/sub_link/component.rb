module Ttt
  module Button
    module SubLink
      class Component < ApplicationComponent
        attr_reader :path, :text
        def initialize(path:, text:)
          @path = path
          @text = text
        end
      end
    end
  end
end
