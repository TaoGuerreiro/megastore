# frozen_string_literal: true

class EndiServices
  class AddUserToFolder < EndiServices
    include ApplicationHelper
    include Turbo::StreamsHelper

    def initialize(store, id)
      super
      @store = store
      @id = id
      @url = "#{ENDI_PATH}/customers/#{@id}"
    end

    def call
      page = mechanize.get(@url)

      form = page.form(action: "/customers/#{@id}?action=addcustomer")

      form.field_with(name: "project_id").options[1].select

      form.click_button
      { status: true, message: "User added to folder" }
    end
  end
end
