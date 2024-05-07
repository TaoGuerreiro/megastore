# frozen_string_literal: true

class EndiServices
  class ResetAuth < EndiServices
    include ApplicationHelper

    def call
      cookie = mechanize.cookie_jar.cookies[0].value
      name = mechanize.cookie_jar.cookies[0].name
      Current.store.update!({
                              endi_auth: "#{name}=#{cookie}"
                            })
    end
  end
end
