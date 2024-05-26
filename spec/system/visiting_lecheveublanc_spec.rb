require 'rails_helper'

RSpec.describe "Visiting le cheveu blanc", type: :system do

  before :each do
    Current.store = create(:store, :with_items)
  end

  it "show all links on the home page" do
    visit root_path
    expect(page).to have_text("Portfolio")
    expect(page).to have_text("Contact")
    expect(page).to have_text("Boutique")
    expect(page).to have_text("À propos")
  end

  it "it can acces to the contact page from the home page" do
    visit root_path
    within "div#desktop" do
      click_on "Contact"
    end
    expect(page).to have_text("Une idée de projet ? Contactez-moi !")
  end

  it "it can acces to the portfolio page from the home page" do
    visit root_path
    within "div#desktop" do
      click_on "Portfolio"
    end
    expect(page).to have_text("POLYFLAMME")
  end

  it "it can acces to the about page from the home page" do
    visit root_path
    within "div#desktop" do
      click_on "À propos"
    end
    expect(page).to have_text("Je suis Clémence, illustratrice indépendante officiant à Nantes sous le pseudonyme Le Cheveu Blanc.")
  end

  it "it can acces to the store page from the home page and buy something" do
    visit root_path
    within "div#desktop" do
      click_on "Boutique"
    end
    expect(page).to have_text("My Item Description")
  end

  scenario "it buy an item, full process" do
    visit store_path

    expect(page).to have_text("My Item Description")

    first(:link, "My Item").click
    expect(page).to have_text("Ajouter au panier")

    click_on "Ajouter au panier"
    expect(page).to have_css("#cart-counter", text: "1")

    # clicker sur la div #cart-counter pour afficher le panier
    find('#cart-counter').click

    expect(page).to have_text("Payement")

    click_on "Payement"
    expect(page).to have_text("Informations complémentaires")

    fill_in "order_intent_email", with: "livre-moi@example.com"
    fill_in "Nom", with: "Florent"
    fill_in "Prénom", with: "Guilbaud"
    fill_in "Adresse", with: "21 rue de la juiverie"
    fill_in "Ville", with: "Nantes"
    fill_in "Code postal", with: "44000"
    select 'France', from: 'Pays'
    fill_in "Téléphone", with: "0674236080"

    click_on "Continuer"

    @store= Store.first

    expect(page).to have_text("Methode de livraison")
    expect(page).to have_text("Colissimo")
    expect(page).to have_text("Chronopost")
    expect(page).to have_text("Colisprive")

    find('#chronopost').click
    expect(page).to have_text("Confirmer")

    VCR.insert_cassette("stripe_checkout_session")
    VCR.insert_cassette("find_shipping_method")

    click_on "Confirmer"
    VCR.eject_cassette(name: "find_shipping_method")
    VCR.eject_cassette(name: "stripe_checkout_session")

    expect(page).to have_text("The specified Checkout Session could not be found")

    # when we don't use cassettes we can use this, but it's not working in the CI, when we click on "Pay" (processing not ended)
    # expect(page).to have_text("Pay with card")
    # find("#cardNumber").set("4242424242424242") #cardNumber
    # find("#cardExpiry").set("12/24")
    # find("#cardCvc").set("123")
    # find("#billingName").set("Florent Guilbaud")
    # click_on "Pay"
    # sleep 40

    @request_body = StripeHelpers.construct_webhook_response("stripe_checkout_session_completed", "checkout.session.completed", Order.last.checkout_session_id)
    post("http://0.0.0.0:3030/webhooks/stripe", params: @request_body.to_json)

    @order = Order.last
    visit(order_path(@order))
    expect(page).to have_text("Je m'en occupe au plus vite !")
    expect(@order.status).to eq("paid")
    expect(@order.shipping).to be_present
    expect(@order.fee).to be_present

    @store_order = StoreOrder.last
    expect(@store_order.store).to eq(@store)
    expect(@store_order.endi_id).to be_present
    expect(@store_order.api_error).to be_nil
  end

  scenario "it buy an item, full process with postal service" do
    visit store_path

    expect(page).to have_text("My Item Description")

    first(:link, "My Item").click
    expect(page).to have_text("Ajouter au panier")

    click_on "Ajouter au panier"
    expect(page).to have_css("#cart-counter", text: "1")

    # clicker sur la div #cart-counter pour afficher le panier
    find('#cart-counter').click

    expect(page).to have_text("Payement")

    click_on "Payement"
    expect(page).to have_text("Informations complémentaires")

    fill_in "order_intent_email", with: "livre-moi@example.com"
    fill_in "Nom", with: "Florent"
    fill_in "Prénom", with: "Guilbaud"
    fill_in "Adresse", with: "21 rue de la juiverie"
    fill_in "Ville", with: "Nantes"
    fill_in "Code postal", with: "44000"
    select 'France', from: 'Pays'
    fill_in "Téléphone", with: "0674236080"

    click_on "Continuer"

    @store= Store.first

    expect(page).to have_text("Methode de livraison")
    expect(page).to have_text("Colissimo")
    expect(page).to have_text("Chronopost")
    expect(page).to have_text("Colisprive")
    expect(page).to have_text("La Poste")

    find('#poste').click
    expect(page).to have_text("Confirmer")

    VCR.insert_cassette("stripe_checkout_session")
    VCR.insert_cassette("find_shipping_method")

    click_on "Confirmer"

    VCR.eject_cassette(name: "find_shipping_method")
    VCR.eject_cassette(name: "stripe_checkout_session")
    expect(page).to have_text("The specified Checkout Session could not be found")


    # when we don't use cassettes we can use this, but it's not working in the CI, when we click on "Pay" (processing not ended)
    # expect(page).to have_text("Pay with card")
    # find("#cardNumber").set("4242424242424242") #cardNumber
    # find("#cardExpiry").set("12/24")
    # find("#cardCvc").set("123")
    # find("#billingName").set("Florent Guilbaud")
    # click_on "Pay"
    # sleep 20

    @request_body = StripeHelpers.construct_webhook_response("stripe_checkout_session_completed", "checkout.session.completed", Order.last.checkout_session_id)
    post("http://0.0.0.0:3030/webhooks/stripe", params: @request_body.to_json)

    @order = Order.last
    visit(order_path(@order))
    expect(page).to have_text("Je m'en occupe au plus vite !")
    expect(@order.status).to eq("paid")
    expect(@order.shipping).to be_present
    expect(@order.shipping.cost_cents).to eq((155))
    expect(@order.shipping.method_carrier).to eq("poste")

    expect(@order.label).to be_an_instance_of(ActiveStorage::Attached::One)
    expect(@order.fee).to be_present

    @store_order = StoreOrder.last
    expect(@store_order.store).to eq(@store)
    expect(@store_order.endi_id).to be_present
    expect(@store_order.api_error).to be_nil
  end
end
