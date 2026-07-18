# frozen_string_literal: true

# Central source of truth for company / brand / SEO details.
# Referenced by the layout, meta-tag helper, JSON-LD, header and footer.
#
# NOTE: values marked TODO are placeholders — replace with real business details
# (phone, address, socials, Search Console token) before launch.
SITE = {
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
