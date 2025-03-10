# frozen_string_literal: true

module Dropdown
  module List
    class Component < ViewComponent::Base
      renders_many :items, types: {
        link: "LinkComponent",
        button: "ButtonComponent",
        text: "TextComponent",
        divider: "DividerComponent"
      }

      class LinkComponent < ViewComponent::Base
        attr_reader :classes

        def initialize(href:, id: nil, name: nil, data: nil, icon: nil, classes: nil) # rubocop:disable Metrics/ParameterLists
          @id = id
          @name = name
          @href = href
          @data = data
          @icon = icon
          @classes = classes
        end

        def call # rubocop:disable Metrics/MethodLength
          all_classes = "#{classes} text-slate-700 block px-4 py-2 text-sm " \
                        "hover:bg-slate-100 whitespace-nowrap flex justify-start items-center"

          link_to(href, data:, id:, class: all_classes, role: "menuitem", tabindex: "-1") do
            if content.present?
              content
            elsif icon.present?
              concat tag.i(class: "mr-2 text-slate-700 #{icon}")
              concat name
            else
              names
            end
          end
        end

        private

        attr_reader :href, :id, :name, :data, :icon
      end

      class ButtonComponent < ViewComponent::Base
        def initialize(name:, action_path: "", icon: nil, **options)
          @name = name
          @action_path = action_path
          @options = options
          @icon = icon
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
