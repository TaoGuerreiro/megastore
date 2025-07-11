# frozen_string_literal: true

module Log
  class Component < ApplicationComponent
    attr_reader :log

    def initialize(log:)
      super()
      @log = log
    end

    def event_type_badge
      class_name = case log.event_type
                   when "wait_like" then "bg-yellow-100 text-yellow-800"
                   when "like_follower_post" then "bg-green-100 text-green-800"
                   when "like_hashtag" then "bg-purple-100 text-purple-800"
                   when "hashtag_cursor_debug" then "bg-pink-100 text-pink-800"
                   when "session_start" then "bg-blue-100 text-blue-800"
                   when "campaign_paused" then "bg-gray-100 text-gray-800"
                   when "hashtag_error" then "bg-red-100 text-red-800"
                   else "bg-content text-content"
                   end
      label = I18n.t(".event_type.#{log.event_type}",
                     default: I18n.t(".event_type.default", type: log.event_type.humanize))
      { label:, class_name: }
    end

    def formatted_wait_until
      wait_until = log.payload["wait_until"] || log.payload["end_hour"]
      return unless wait_until

      begin
        l(Time.parse(wait_until), format: :short)
      rescue StandardError
        wait_until.to_s
      end
    end
  end
end
