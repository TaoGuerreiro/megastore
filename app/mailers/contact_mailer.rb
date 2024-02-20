# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def new_message_from_store
    @contact = params[:contact]
    mail to: 'hello@lecheveublanc.fr', subject: 'Nouveau message depuis le site'
  end
end
