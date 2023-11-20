class PagesController < ApplicationController
  layout "application"

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
      begin
        ContactMailer.with(contact: @contact).new_message_from_store.deliver_now
        redirect_to root_path, notice: "Message bien envoyé", status: :see_other
      rescue => e
        flash[:error] = "Une erreur est survenue lors de l'envoi du message. Veuillez réessayer."
        render "#{Current.store.slug}/contact", status: :unprocessable_entity
      end
    else
      render "#{Current.store.slug}/contact", status: :unprocessable_entity
    end
  end

  def about
    render template: "#{Current.store.slug}/about"
  end

  private

  def contact_params
    params.require(:contact).permit(:email, :full_name, :content)
  end
end
