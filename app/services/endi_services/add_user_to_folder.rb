# frozen_string_literal: true

module EndiServices
  class AddUserToFolder
    include ApplicationHelper
    include Turbo::StreamsHelper

    def initialize(store, id)
      @mechanize = EndiServices::Auth.new.call
      @store = store
      @id = id
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/customers/#{@id}"
    end

    def call
      page = @mechanize.get(@url)

      form = page.form(action: "/customers/#{@id}?action=addcustomer")

      folder_index = Rails.env.production? ? 2 : 1
      form.field_with(name: "project_id").options[folder_index].select

      form.click_button
      { status: true, message: "User added to folder" }
    end
  end
end
