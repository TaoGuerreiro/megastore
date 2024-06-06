# frozen_string_literal: true

module Dropdown
  class Component < ViewComponent::Base
    renders_many :lists, "::Dropdown::List::Component"

    def initialize(pop_direction: :right)
      @pop_direction = pop_direction
    end

    private

    attr_reader :pop_direction

    POP_DIRECTIONS = {
      right: "origin-top-right right-0",
      left: "origin-top-left left-0"
    }.freeze
    def pop_direction_class
      POP_DIRECTIONS[pop_direction.to_sym]
    end
  end
end
