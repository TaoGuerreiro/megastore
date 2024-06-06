# frozen_string_literal: true

module Dropdown
  module List
    class Component < ViewComponent::Base
      renders_many :items, types: {
        link: "LinkComponent",
        button: "ButtonComponent",
        text: "TextComponent",
        divider: "DividerComponent",
      }

      class LinkComponent < ViewComponent::Base
        def initialize(href:, name: nil, data: nil)
          @name = name
          @href = href
          @data = data
        end

        def call
          if content.present?
            link_to(href,
                    data:,
                    class: "text-slate-700 block px-4 py-2 text-sm hover:bg-slate-100",
                    role: "menuitem",
                    tabindex: "-1") { content }
          else
            link_to name, href,
                    data:,
                    class: "text-slate-700 block px-4 py-2 text-sm hover:bg-slate-100",
                    role: "menuitem",
                    tabindex: "-1"
          end
        end

        private

        attr_reader :name, :href, :data
      end

      class ButtonComponent < ViewComponent::Base
        def initialize(name:, action_path: "", **options)
          @name = name
          @action_path = action_path
          @options = options
        end

        def call
          button_to name, action_path,
                    **options,
                    class: "w-full text-left text-slate-700 px-4 py-2 text-sm hover:bg-slate-100",
                    role: "menuitem",
                    tabindex: "-1"
        end

        private

        attr_reader :name, :action_path, :options
      end

      class TextComponent < ViewComponent::Base
        def call
          content_tag(
            :div,
            content,
            class: "w-full text-left text-slate-900 px-4 py-2 text-sm font-medium"
          )
        end
      end

      class DividerComponent < ViewComponent::Base
        def call
          classes = <<-TXT
            w-full h-px px-4 border-b border-solid border-gray-200 border-x-0 border-t-0
          TXT
          content_tag(
            :div,
            content,
            class: classes
          )
        end
      end
    end
  end
end
