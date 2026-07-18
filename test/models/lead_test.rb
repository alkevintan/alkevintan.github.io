# frozen_string_literal: true

require "test_helper"

class LeadTest < ActiveSupport::TestCase
  def valid_attrs
    { name: "Juan Dela Cruz", email: "juan@example.com", message: "I need a website." }
  end

  test "valid with required attributes" do
    assert Lead.new(valid_attrs).valid?
  end

  test "requires name, email and message" do
    lead = Lead.new
    assert_not lead.valid?
    assert lead.errors.key?(:name)
    assert lead.errors.key?(:email)
    assert lead.errors.key?(:message)
  end

  test "rejects an invalid email" do
    assert_not Lead.new(valid_attrs.merge(email: "not-an-email")).valid?
  end

  test "rejects a project_type outside the allowed list" do
    assert_not Lead.new(valid_attrs.merge(project_type: "Spaceship")).valid?
    assert Lead.new(valid_attrs.merge(project_type: "Website")).valid?
  end

  test "defaults to the new_lead status" do
    assert_equal "new_lead", Lead.new.status
  end

  test "display_name falls back to email" do
    assert_equal "juan@example.com", Lead.new(email: "juan@example.com").display_name
  end
end
