# frozen_string_literal: true

module Tabs
  class Component < ApplicationComponent
    def initialize(tabs:)
      @tabs = tabs
    end

    attr_reader :tabs

    private

    def active_tab
      request.path
    end

    def tab_classes(tab)
      tab[:path] == active_tab ? active_tab_classes : inactive_tab_classes
    end

    def active_tab_classes
      "bg-light rounded-none rounded-t-lg text-contrast hover:text-indigo-800"
    end

    def inactive_tab_classes
      "text-contrast hover:text-primary hover:bg-light hover:rounded-none hover:rounded-t-lg"
    end
  end
end
