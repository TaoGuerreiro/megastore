require 'rails_helper'

RSpec.describe "Visiting le cheveu blanc", type: :system do
  before :each do
    store = create(:store, :with_items)
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
      expect(page).to have_text("Polyflamme")
    end

    it "it can acces to the about page from the home page" do
      visit root_path
      within "div#desktop" do
        click_on "À propos"
      end
      expect(page).to have_text("Je suis Clémence, illustratrice indépendante officiant à Nantes sous le pseudonyme Le Cheveu Blanc.")
    end

    it "it can acces to the store page from the home page" do
      visit root_path
      within "div#desktop" do
        click_on "Boutique"
      end
      expect(page).to have_text("My Item Description")
    end

end
