# frozen_string_literal: true

class Step::Component < ApplicationComponent
  def initialize(steps:, current_step:)
    @before = current_step - 1
    @after = [steps - current_step, 0].max
    @last_step = current_step == steps
  end
end
