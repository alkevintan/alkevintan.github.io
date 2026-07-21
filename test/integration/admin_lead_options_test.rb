# frozen_string_literal: true

require "test_helper"

class AdminLeadOptionsTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "contact form falls back to default options when empty" do
    assert_equal 0, LeadOption.count
    get contact_path
    assert_response :success
    assert_select "select[name=?] option", "lead[project_type]", minimum: 6
    assert_match "E-commerce", @response.body
  end

  test "published options replace the defaults" do
    LeadOption.create!(field: "project_type", label: "Consulting", position: 0)
    get contact_path
    assert_select "select[name=?] option", "lead[project_type]", text: "Consulting"
    assert_select "select[name=?] option", "lead[project_type]", text: "Website", count: 0
  end

  test "lead accepts an admin-added project type and rejects unknown values" do
    LeadOption.create!(field: "project_type", label: "Consulting", position: 0)
    assert Lead.new(name: "A", email: "a@b.co", message: "hi", project_type: "Consulting").valid?
    refute Lead.new(name: "A", email: "a@b.co", message: "hi", project_type: "Bogus").valid?
  end

  test "admin can create an option" do
    assert_difference -> { LeadOption.count }, 1 do
      post admin_lead_options_path, params: { lead_option: { field: "timeline", label: "This week", position: 0 } }
    end
    assert_redirected_to admin_lead_options_path
  end

  test "contact page copy is editable" do
    ContentBlock.create!(page: "contact", key: "header_title", content: "Reach out today")
    get contact_path
    assert_match "Reach out today", @response.body
  end
end
