# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "message@chalky.fr"
  layout "mailer"
end
