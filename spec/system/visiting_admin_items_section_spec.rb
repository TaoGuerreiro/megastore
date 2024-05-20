require 'rails_helper'

RSpec.describe "Visiting admin items section", type: :system do

  before :each do
    @store = create(:store, :with_items)
    create(:inactive_item, store: @store)
    @admin = @store.admin

    Current.store = @store
  end

  it "display the items index with 3 items" do
    login_as(@admin)
    visit admin_items_path
    expect(page).to have_text("Articles")
    expect(page).to have_text("3 articles en ligne")
    expect(page).to have_text("1 article hors ligne")
    expect(page).to have_text("0 articles archivé")
    expect(page).to have_text("Ajouter un article")
  end

  it "edit an item" do
    login_as(@admin)
    visit admin_items_path
    find("[for='cart_1']").click
    click_on "Editer"

    expect(page).to have_text("Informations")

    fill_in "Nom", with: "THIS IS THE NAME"
    click_on "Modifier"

    expect(page).to have_text("THIS IS THE NAME")
  end

  it "archive an item" do
    login_as(@admin)
    visit admin_items_path
    find("[for='cart_1']").click
    click_on "Editer"
    expect(page).to have_text("Informations")
    click_on "Archiver"

    expect(page).to have_text("2 articles en ligne")
    expect(page).to have_text("1 article hors ligne")
    expect(page).to have_text("1 article archivé")
  end

  it "add a item to the stock" do
    login_as(@admin)
    visit admin_items_path
    @item = Item.first
    within("#item_#{@item.id}") do
      click_link(href: add_stock_admin_item_path(@item ))

      expect(page).to have_text("11")
    end
  end

  it "remove 2 item of the stock" do
    login_as(@admin)
    visit admin_items_path
    @item = Item.first
    within("#item_#{@item.id}") do
      click_link(href: remove_stock_admin_item_path(@item ))
      expect(page).to have_text("9")
      click_link(href: remove_stock_admin_item_path(@item ))
      expect(page).to have_text("8")
    end
  end

  it "pass an item to offline" do
    login_as(@admin)
    visit admin_items_path
    @item = Item.first
    within("#item_#{@item.id}") do
      find("[type='checkbox']").click
    end
    click_on "Offline"

    visit admin_items_path
    expect(page).to have_text("2 articles en ligne")
    expect(page).to have_text("2 articles hors ligne")
  end

  it "pass an item to online" do
    login_as(@admin)
    visit admin_items_path
    @item = Item.last
    within("#item_#{@item.id}") do
      find("[type='checkbox']").click
    end
    click_on "Online"

    visit admin_items_path # TODO updating count modal
    expect(page).to have_text("4 articles en ligne")
  end

  it "remove an item" do
    login_as(@admin)
    visit admin_items_path
    find("[for='cart_1']").click
    click_on "Supprimer"
    visit admin_items_path # TODO updating count modal
    expect(page).to have_text("2 articles en ligne")
    expect(page).to have_text("1 article hors ligne")
    expect(page).to have_text("0 articles archivé")

    expect(Item.count).to eq(3)
  end
end
