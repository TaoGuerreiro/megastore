# frozen_string_literal: true

module Header
  class Component < ApplicationComponent
    renders_one :tabs
    renders_one :backlink
    renders_one :options
    renders_one :action_link
    renders_one :pagination
  end
end
