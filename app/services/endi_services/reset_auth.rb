# frozen_string_literal: true

module EndiServices
  class ResetAuth
    include ApplicationHelper

    def initialize(user)
      @user = user
    end

    def call
      mechanize = EndiServices::Auth.new.call

      @user.update!({
                      endi_auth: "#{mechanize.cookie_jar.cookies[0].name}=#{mechanize.cookie_jar.cookies[0].value}"
                    })
    end
  end
end
