require 'rails_helper'

RSpec.describe Store, type: :model do

  it "has an endi_id" do
    store = create(:store, endi_profile: true)
    expect(store.endi_id).to be_present
    expect(store.endi_id).to be_a(Integer)
  end

  it 'has a valid factory' do
    expect(build(:store)).to be_valid
  end

  it 'is valid with valid attributes' do
    store = create(:store)
    expect(store).to be_valid
  end

  it 'is not valid without a name' do
    store = build(:store, name: nil)
    expect(store).not_to be_valid
    expect(store.errors[:name]).to include("doit être rempli(e)")
  end

  it 'is not valid without a slug' do
    store = build(:store, slug: nil)
    expect(store).not_to be_valid
    expect(store.errors[:slug]).to include("doit être rempli(e)")
  end

  it 'is not valid without an admin' do
    store = build(:store, admin: nil)
    expect(store).not_to be_valid
    expect(store.errors[:admin]).to include("doit exister")
  end

  it 'is not valid without a country' do
    store = build(:store, country: nil)
    expect(store).not_to be_valid
    expect(store.errors[:country]).to include("doit être rempli(e)")
  end

  it 'is not valid without an address' do
    store = build(:store, address: nil)
    expect(store).not_to be_valid
    expect(store.errors[:address]).to include("doit être rempli(e)")
  end

  it 'is not valid without a postal code' do
    store = build(:store, postal_code: nil)
    expect(store).not_to be_valid
    expect(store.errors[:postal_code]).to include("doit être rempli(e)")
  end

  it 'is not valid without a city' do
    store = build(:store, city: nil)
    expect(store).not_to be_valid
    expect(store.errors[:city]).to include("doit être rempli(e)")
  end
end
