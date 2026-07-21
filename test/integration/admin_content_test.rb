# frozen_string_literal: true

require "test_helper"

class AdminContentTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "home renders registry defaults when DB is empty" do
    assert_equal 0, ContentBlock.count
    get root_path
    assert_response :success
    assert_match "Software that grows your business", @response.body
    assert_match "Built to rank", @response.body # hero stat default
  end

  test "content block overrides the default on the public page" do
    ContentBlock.create!(page: "home", key: "hero_heading", content: "Custom Hero Heading")
    get root_path
    assert_match "Custom Hero Heading", @response.body
    assert_no_match "Software that grows your business", @response.body
  end

  test "blank content block falls back to the default" do
    ContentBlock.create!(page: "home", key: "hero_heading", content: "")
    get root_path
    assert_match "Software that grows your business", @response.body
  end

  test "content items replace defaults when present" do
    ContentItem.create!(page: "home", section: "hero_stats", title: "Cloud", body: "AWS", position: 0)
    get root_path
    assert_match "Cloud", @response.body
    assert_no_match "Built to rank", @response.body
  end

  test "editor lists pages and renders a page form" do
    get admin_content_index_path
    assert_response :success
    get edit_admin_content_path("home")
    assert_response :success
    assert_select "textarea[name=?]", "content[blocks][hero_body]"
  end

  test "update upserts blocks and items and reflects on the page" do
    patch admin_content_path("home"), params: {
      content: {
        blocks: { hero_heading: "Brand New Heading" },
        sections: {
          hero_stats: {
            "0" => { id: "", title: "Speed", body: "Fast sites" },
            "1" => { id: "", title: "", body: "" }
          }
        }
      }
    }
    assert_redirected_to edit_admin_content_path("home")
    assert_equal "Brand New Heading", ContentBlock.value_for("home", "hero_heading")
    assert_equal %w[Speed], ContentItem.for_section("home", "hero_stats").ordered.pluck(:title)

    get root_path
    assert_match "Brand New Heading", @response.body
    assert_match "Fast sites", @response.body
  end

  test "unknown page returns 404" do
    get edit_admin_content_path("nope")
    assert_response :not_found
  end
end
