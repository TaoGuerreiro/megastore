require "application_system_test_case"

class Ttt::HomeTest < ApplicationSystemTestCase
  setup do
    @store = Current.store
  end

  test "visiting the home page" do
    visit ttt_root_path
    assert_selector "h2", text: "Les campagnes de crowfonding en cours !"
    assert_selector "h2", text: "Les autre sortie signé TTT !"
  end

  test "scroll down button is present and clickable" do
    visit ttt_root_path
    assert_selector "i.fa-arrow-down", count: 2
    assert_selector "[data-controller='scroll-down']", count: 2
  end

  test "logo component is rendered" do
    visit ttt_root_path
    assert_selector "[data-controller='t']"
  end

  test "items sections are displayed correctly" do
    visit ttt_root_path

    within ".max-w-5xl", match: :first do
      assert_selector "h2", text: "Les campagnes de crowfonding en cours !"
      assert_selector ".text-contrast"
    end

    within ".max-w-5xl:last-child" do
      assert_selector "h2", text: "Les autre sortie signé TTT !"
      assert_selector ".text-contrast"
    end
  end
end
