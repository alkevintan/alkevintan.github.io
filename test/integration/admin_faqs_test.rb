# frozen_string_literal: true

require "test_helper"

class AdminFaqsTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "faqs_for falls back to defaults when no rows exist" do
    assert_equal 0, Faq.count
    get services_path
    assert_response :success
    assert_match "How do your quotes work?", @response.body
  end

  test "published DB rows replace defaults on the public page" do
    Faq.create!(page: "services", question: "Custom Q?", answer: "Custom A", position: 0)
    get services_path
    assert_response :success
    assert_match "Custom Q?", @response.body
    assert_no_match "How do your quotes work?", @response.body
  end

  test "hidden faqs are not rendered" do
    Faq.create!(page: "services", question: "Hidden Q?", answer: "x", published: false)
    get services_path
    assert_no_match "Hidden Q?", @response.body
  end

  test "admin can create a faq" do
    assert_difference -> { Faq.count }, 1 do
      post admin_faqs_path, params: { faq: { page: "web_development", question: "New?", answer: "Yes", position: 9 } }
    end
    assert_redirected_to admin_faqs_path
  end
end
