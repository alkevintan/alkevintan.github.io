# frozen_string_literal: true

class CreateSiteSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      # Brand
      t.string :name
      t.string :legal_name
      t.string :tagline
      t.text   :description
      t.string :domain
      t.string :url
      t.string :locale

      # Contact / NAP
      t.string :email
      t.string :phone
      t.string :phone_link
      t.string :whatsapp
      t.string :address_locality
      t.string :address_region
      t.string :address_area
      t.string :address_country
      t.string :address_country_name

      # Service areas (one per line)
      t.text :service_areas

      # Social profiles
      t.string :facebook_url
      t.string :linkedin_url
      t.string :instagram_url
      t.string :github_url

      # Analytics / verification / OG
      t.string :ga4_measurement_id
      t.string :google_site_verification
      t.string :default_og_image

      t.timestamps
    end
  end
end
