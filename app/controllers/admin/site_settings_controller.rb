# frozen_string_literal: true

module Admin
  # Single-row site settings (brand, contact/NAP, socials, analytics, OG image).
  class SiteSettingsController < BaseController
    before_action :set_site_setting

    def edit; end

    def update
      if @site_setting.update(site_setting_params)
        redirect_to edit_admin_site_setting_path, notice: "Site settings saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_site_setting
      @site_setting = SiteSetting.for_edit
    end

    def site_setting_params
      params.require(:site_setting).permit(
        :name, :legal_name, :tagline, :description, :domain, :url, :locale,
        :email, :phone, :phone_link, :whatsapp,
        :address_locality, :address_region, :address_area,
        :address_country, :address_country_name,
        :service_areas,
        :facebook_url, :linkedin_url, :instagram_url, :github_url,
        :ga4_measurement_id, :google_site_verification, :default_og_image, :og_image
      )
    end
  end
end
