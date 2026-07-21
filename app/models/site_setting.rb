# frozen_string_literal: true

# Single-row, admin-editable replacement for the frozen SITE_DEFAULTS hash.
# Every field falls back to SITE_DEFAULTS when blank, so an empty (or absent)
# row still renders the site exactly as the old hardcoded constant did.
#
# Read it via the drop-in `SITE[:key]` (see config/initializers/site.rb) or
# directly as `SiteSetting.current`.
class SiteSetting < ApplicationRecord
  has_one_attached :og_image

  # The one and only settings row. Memoized per request on Current so a page
  # render issues a single query. Returns an unsaved defaults-only record when
  # no row exists yet (public reads never write).
  def self.current
    Current.site_setting ||= (first || new)
  end

  # Persisted row for the admin editor (creates it on first edit).
  def self.for_edit
    first || create!
  end

  # Full SITE-shaped hash: defaults overlaid with any non-blank DB values.
  # Memoized on the (per-request) instance.
  def to_site_hash
    @to_site_hash ||= begin
      d = SITE_DEFAULTS
      {
        name:        name.presence        || d[:name],
        legal_name:  legal_name.presence  || d[:legal_name],
        tagline:     tagline.presence     || d[:tagline],
        description: description.presence  || d[:description],
        domain:      domain.presence      || d[:domain],
        url:         url.presence         || d[:url],
        locale:      locale.presence      || d[:locale],
        email:       email.presence       || d[:email],
        phone:       phone.presence       || d[:phone],
        phone_link:  phone_link.presence  || d[:phone_link],
        whatsapp:    whatsapp.presence    || d[:whatsapp],
        address: {
          locality:     address_locality.presence     || d[:address][:locality],
          region:       address_region.presence       || d[:address][:region],
          area:         address_area.presence         || d[:address][:area],
          country:      address_country.presence      || d[:address][:country],
          country_name: address_country_name.presence || d[:address][:country_name]
        },
        service_areas: service_areas_list.presence || d[:service_areas],
        social: {
          facebook:  facebook_url.to_s,
          linkedin:  linkedin_url.to_s,
          instagram: instagram_url.to_s,
          github:    github_url.to_s
        },
        ga4_measurement_id:       ga4_measurement_id.presence       || d[:ga4_measurement_id],
        google_site_verification: google_site_verification.presence || d[:google_site_verification],
        default_og_image:         resolved_og_image
      }
    end
  end

  # Service areas as a clean array (one entry per line in the textarea).
  def service_areas_list
    service_areas.to_s.split("\n").map(&:strip).reject(&:blank?)
  end

  private

  # Uploaded OG image (path) if attached, else the filename column / default.
  def resolved_og_image
    if og_image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(og_image, only_path: true)
    else
      default_og_image.presence || SITE_DEFAULTS[:default_og_image]
    end
  end
end
