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

  scenario "it can acces to the show page of an item" do
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

    expect(page).to have_text("Methode de livraison")
    expect(page).to have_text("Colissimo")
    expect(page).to have_text("Chronopost")
    expect(page).to have_text("Colisprive")

    find('#chronopost').click
    expect(page).to have_text("Confirmer")

    click_on "Confirmer"
    expect(page).to have_text("Payer par carte")

    find("#cardNumber").set("4242424242424242") #cardNumber
    find("#cardExpiry").set("12/24")
    find("#cardCvc").set("123")
    find("#billingName").set("Florent Guilbaud")

    click_on "Payer"

    sleep 20
  end
end
