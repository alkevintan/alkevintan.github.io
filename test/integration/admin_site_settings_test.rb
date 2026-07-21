# frozen_string_literal: true

require "test_helper"

class AdminSiteSettingsTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "edit page renders" do
    get edit_admin_site_setting_path
    assert_response :success
    assert_select "form"
  end

  test "update persists and reflects on the public site" do
    patch admin_site_setting_path, params: { site_setting: { email: "new@aktive.test", name: "Aktive New" } }
    assert_redirected_to edit_admin_site_setting_path

    setting = SiteSetting.first
    assert_equal "new@aktive.test", setting.email
    assert_equal "Aktive New", setting.name

    get root_path
    assert_response :success
    assert_match "new@aktive.test", @response.body
  end

  test "requires authentication" do
    sign_out
    get edit_admin_site_setting_path
    assert_redirected_to new_session_path
  end
end
