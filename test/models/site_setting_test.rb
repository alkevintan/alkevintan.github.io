# frozen_string_literal: true

require "test_helper"

class SiteSettingTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "SITE falls back to defaults when no row exists" do
    assert_equal SITE_DEFAULTS[:email], SITE[:email]
    assert_equal SITE_DEFAULTS[:service_areas], SITE[:service_areas]
    assert_equal SITE_DEFAULTS[:default_og_image], SITE[:default_og_image]
    assert_equal SITE_DEFAULTS.dig(:address, :locality), SITE.dig(:address, :locality)
  end

  test "non-blank DB values override defaults, blanks fall back" do
    SiteSetting.create!(name: "Override Co", email: "hi@override.test", facebook_url: "https://fb/x")
    Current.reset

    assert_equal "Override Co", SITE[:name]
    assert_equal "hi@override.test", SITE[:email]
    assert_equal SITE_DEFAULTS[:tagline], SITE[:tagline], "blank tagline should fall back"
    assert_equal "https://fb/x", SITE[:social][:facebook]
    assert_equal "", SITE[:social][:linkedin]
  end

  test "service_areas textarea parses to an array" do
    SiteSetting.create!(service_areas: "Cebu\n Davao \n\n")
    Current.reset

    assert_equal %w[Cebu Davao], SITE[:service_areas]
  end
end
