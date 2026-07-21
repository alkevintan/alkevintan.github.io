# frozen_string_literal: true

require "test_helper"

class AdminMenuItemsTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "header falls back to default nav links when empty" do
    assert_equal 0, MenuItem.count
    get root_path
    assert_response :success
    assert_select "nav[aria-label=?] a", "Main", minimum: 5
    assert_match "Portfolio", @response.body
  end

  test "published rows replace the default header nav" do
    MenuItem.create!(menu: "header", label: "Pricing", url: "/pricing", position: 0)
    get root_path
    assert_select "nav[aria-label=?] a", "Main", text: "Pricing"
    assert_select "nav[aria-label=?] a", "Main", text: "Portfolio", count: 0
  end

  test "hidden links are not rendered" do
    MenuItem.create!(menu: "footer_company", label: "Secret", url: "/secret", published: false)
    get root_path
    assert_no_match "Secret", @response.body
  end

  test "admin can create a menu link" do
    assert_difference -> { MenuItem.count }, 1 do
      post admin_menu_items_path, params: { menu_item: { menu: "header", label: "Docs", url: "/docs", position: 9 } }
    end
    assert_redirected_to admin_menu_items_path
  end

  test "global content editor renders" do
    get edit_admin_content_path("global")
    assert_response :success
    assert_select "textarea[name=?]", "content[blocks][footer_blurb]"
  end
end
