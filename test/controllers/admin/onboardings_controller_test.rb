require "test_helper"

class Admin::OnboardingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get admin_onboardings_show_url
    assert_response :success
  end
end
