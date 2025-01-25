# frozen_string_literal: true

class PagesController < ApplicationController
  layout "application"
  before_action :set_store

  def landing; end

  def home
    @items = @store.items.where(status: :active)
    @collections = @store.collections_with_items

    render "#{@store.slug}/home"
  end

  def contact
    @contact = Contact.new
    render "#{@store.slug}/contact"
  end

  def send_message
    @contact = Contact.new(contact_params)

    if @contact.valid?
      ContactMailer.with(contact: @contact, store: @store).new_message_from_store.deliver_now
      redirect_to root_path, status: :see_other, notice: t(".success")
    else
      render "#{@store.slug}/contact", status: :unprocessable_entity, notice: t(".error")
    end
  end

  def about
    @contact = Contact.new

    render template: "#{@store.slug}/about"
  end

  def confidentiality; end

  def authors
    @authors = Author.order(:nickname)
    render "#{@store.slug}/authors"
  end

  def author
    @author = Author.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.update("modale", partial: "ttt/author") }
    end
  end

  def portfolio
    render template: "#{@store.slug}/portfolio"
  end

  private

  def set_store
    @store = Current.store
  end

  def contact_params
    params.require(:contact).permit(:email, :full_name, :content, :nickname)
  end
end
