# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'hello@lecheveublanc.fr'
  layout 'mailer'
end
