# frozen_string_literal: true

module Step
  class Component < ApplicationComponent
    def initialize(steps:, current_step:)
      super
      @before = current_step - 1
      @after = [steps - current_step, 0].max
      @last_step = current_step == steps
    end
  end
end
