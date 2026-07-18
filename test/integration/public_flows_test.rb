# frozen_string_literal: true

require "test_helper"

class PublicFlowsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "home page renders" do
    get root_path
    assert_response :success
    assert_select "h1"
  end

  test "contact page renders" do
    get contact_path
    assert_response :success
  end

  test "blog index renders" do
    get blog_path
    assert_response :success
  end

  test "sitemap and robots render" do
    get sitemap_path(format: :xml)
    assert_response :success
    get robots_path(format: :text)
    assert_response :success
  end

  test "creating a lead stores it, redirects, and queues a notification" do
    assert_difference -> { Lead.count }, 1 do
      assert_enqueued_emails 1 do
        post contact_path, params: {
          lead: { name: "Ana", email: "ana@example.com", message: "Hi there" },
          form_loaded_at: 30.seconds.ago.to_i
        }
      end
    end
    assert_redirected_to thank_you_path
  end

  test "honeypot blocks spam without storing" do
    assert_no_difference -> { Lead.count } do
      post contact_path, params: {
        lead: { name: "Bot", email: "bot@example.com", message: "spam" },
        website: "http://spam.example"
      }
    end
    assert_redirected_to thank_you_path
  end

  test "invalid lead re-renders the form" do
    assert_no_difference -> { Lead.count } do
      post contact_path, params: { lead: { name: "", email: "bad", message: "" },
                                   form_loaded_at: 30.seconds.ago.to_i }
    end
    assert_response :unprocessable_entity
  end

  test "admin requires authentication" do
    get admin_root_path
    assert_redirected_to new_session_path
  end
end
