require 'rails_helper'

RSpec.describe "Endi Invoice", type: :request do

  before(:all) do
    @store = create(:store, :with_items)
    Current.store = @store
    @order = create(:order, store: @store)
    @store_order = create(:store_order, store: @store)
    @store_order_item = create(:store_order_item, orderable: @order.shipping, store_order: @store_order)
  end

  describe "creating invoice" do
    it "will return a 200 if successful" do
      VCR.use_cassette("create_invoice") do
        @response = EndiServices::NewInvoice.new(@store_order, @store).call
      end
      VCR.eject_cassette
      expect(@response.code).to eq(200)
    end
  end

  describe "get task line groups" do
    it "will return a Integer of the task_line_group_id" do
      VCR.use_cassette("get_task_line_groups") do
        @response = EndiServices::TaskLineGroup.new(@store_order, @store).call
      end
      VCR.eject_cassette
      expect(@response).to be_an_instance_of(Integer)
    end
  end

  describe "add invoice line" do
    it "will return a 200 if successful" do
      VCR.use_cassette("add_invoice_line") do
        @response = EndiServices::AddBillLine.new(@store_order_item, @store).call
      end
      VCR.eject_cassette
      expect(@response.code).to eq(200)
    end
  end
end
