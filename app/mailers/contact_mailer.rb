# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def new_message_from_store
    @contact = params[:contact]
    @store = params[:store]
    mail to: @store.admin.email, subject: t(".subject")
  end
end
