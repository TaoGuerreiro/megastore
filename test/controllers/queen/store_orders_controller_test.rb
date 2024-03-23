require "test_helper"

class Queen::StoreOrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get queen_store_orders_index_url
    assert_response :success
  end

  test "should get show" do
    get queen_store_orders_show_url
    assert_response :success
  end
end
