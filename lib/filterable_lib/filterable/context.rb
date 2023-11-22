# frozen_string_literal: true

module Filterable
  class Context
    attr_reader :model, :name, :submit_path, :views_owner

    delegate :filterable, to: :model

    def initialize(model, name, submit_path, views_owner)
      @model = model
      @name = name
      @submit_path = submit_path
      @views_owner = views_owner
    end
  end
end
