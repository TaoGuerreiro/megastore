# frozen_string_literal: true

class PagesController < ApplicationController
  layout "application"

  def landing
  end

  def home
    @items = Current.store.items.where(status: :active)
    render "#{Current.store.slug}/home"
  end

  def contact
    @contact = Contact.new
    render "#{Current.store.slug}/contact"
  end

  def send_message
    @contact = Contact.new(contact_params)

    if @contact.valid?
      ContactMailer.with(contact: @contact, store: Current.store).new_message_from_store.deliver_now
      redirect_to root_path, status: :see_other, success: "Message bien envoyé"
    else
      render "#{Current.store.slug}/contact", status: :unprocessable_entity
    end
  end

  def about
    render template: "#{Current.store.slug}/about"
  end

  def portfolio
    render template: "#{Current.store.slug}/portfolio"
  end

  private

  def contact_params
    params.require(:contact).permit(:email, :full_name, :content, :nickname)
  end
end
