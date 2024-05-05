# frozen_string_literal: true

module Admin
  class InstagramsController < AdminController
    def show
      agent = Mechanize.new
      agent.user_agent_alias = "Mac Safari"
      agent.log = Logger.new "mech.log"

      agent.get("https://www.instagram.com/accounts/login/?force_classic_login")

      # raise
    end
  end
end
