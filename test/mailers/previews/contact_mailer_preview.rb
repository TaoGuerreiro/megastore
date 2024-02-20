# frozen_string_literal: true

class ContactMailerPreview < ActionMailer::Preview
  def new_message_from_store
    contact = Contact.new(full_name: 'John Doe', email: 'text@test.fr', content: "Hello, I'm John Doe")
    ContactMailer.with(contact:).new_message_from_store
  end
end
