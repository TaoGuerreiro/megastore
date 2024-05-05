# frozen_string_literal: true

module EndiServices
  class ResetAuth
    include ApplicationHelper

    def initialize(store)
      @store = store
    end

    def call
      mechanize = EndiServices::Auth.new.call

      @store.update!({
                       endi_auth: "#{mechanize.cookie_jar.cookies[0].name}=#{mechanize.cookie_jar.cookies[0].value}"
                     })
    end
  end
end
