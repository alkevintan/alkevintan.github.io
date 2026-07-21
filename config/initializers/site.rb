# frozen_string_literal: true

# Fallback company / brand / SEO details.
#
# These are the built-in defaults. At runtime the site reads from the editable
# `SiteSetting` row (Admin → Site Settings); any field left blank there falls
# back to the matching value here, so the site renders correctly even with an
# empty database. Referenced through the drop-in `SITE[:key]` interface below.
SITE_DEFAULTS = {
  name: "AktiveSolutions",
  legal_name: "AktiveSolutions",
  tagline: "Web & Mobile App Development in the Philippines",
  # Default meta description used when a page doesn't set its own.
  description: "AktiveSolutions builds high-performance websites, web apps and " \
               "mobile apps for businesses in Bicol and across the Philippines. " \
               "Get a free project quote.",
  domain: "aktivesolutions.com",
  url: "https://aktivesolutions.com",
  locale: "en_PH",

  # Contact / NAP (Name-Address-Phone) — keep consistent with Google Business Profile.
  email: "hello@aktivesolutions.com",       # TODO: confirm real inbox
  phone: "+63 000 000 0000",                # TODO: real phone
  phone_link: "+630000000000",              # TODO: E.164, no spaces
  whatsapp: "",                             # TODO: optional, digits only e.g. 639XXXXXXXXX
  address: {
    locality: "Naga City",
    region: "Camarines Sur",
    area: "Bicol Region",
    country: "PH",
    country_name: "Philippines"
  },
  # Geographic areas the business serves (used in LocalBusiness JSON-LD + copy).
  service_areas: [
    "Naga City", "Legazpi City", "Sorsogon", "Daet", "Iriga City",
    "Bicol Region", "Philippines"
  ],

  # Social profiles (used for footer links + sameAs in JSON-LD). Leave blank to hide.
  social: {
    facebook: "",   # TODO
    linkedin: "",   # TODO
    instagram: "",  # TODO
    github: ""       # TODO
  },

  # Analytics / verification (leave blank to disable the tag).
  ga4_measurement_id: "",          # TODO: e.g. "G-XXXXXXXXXX"
  google_site_verification: "",    # TODO: Search Console meta token

  # Default Open Graph image (relative to /public or an asset path).
  default_og_image: "og-default.png"
}.freeze

# Drop-in replacement for the old frozen SITE hash. `SITE[:key]` now resolves
# through the editable SiteSetting row (with SITE_DEFAULTS as the fallback),
# so every existing `SITE[:key]` reference keeps working unchanged.
class SiteConfig
  def [](key)
    SiteSetting.current.to_site_hash.fetch(key) { SITE_DEFAULTS[key] }
  # Stay resilient during boot / asset precompile / migrations, when the DB or
  # the site_settings table may not exist yet — fall back to the static default.
  rescue StandardError
    SITE_DEFAULTS[key]
  end

  def fetch(key, *default)
    value = self[key]
    return value unless value.nil?

    default.empty? ? (block_given? ? yield(key) : SITE_DEFAULTS.fetch(key)) : default.first
  end

  def dig(key, *rest)
    value = self[key]
    rest.empty? ? value : value&.dig(*rest)
  end

  def to_h
    SITE_DEFAULTS.merge(SiteSetting.current.to_site_hash)
  rescue StandardError
    SITE_DEFAULTS
  end

  # Forward any other Hash read method (keys, values, each, key?, …) to the
  # resolved hash so SITE stays a drop-in for the old frozen constant.
  def respond_to_missing?(name, include_private = false)
    to_h.respond_to?(name, include_private) || super
  end

  def method_missing(name, *args, &block)
    hash = to_h
    return hash.public_send(name, *args, &block) if hash.respond_to?(name)

    super
  end
end

SITE = SiteConfig.new
