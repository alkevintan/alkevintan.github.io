# frozen_string_literal: true

# Registry of editable marketing-page copy. Single source of truth for:
#   * the built-in default text (view fallback when nothing is in the DB),
#   * the admin content editor (which fields/sections exist + their labels),
#   * seeding.
#
# `blocks` are singular fields (page, key) stored in ContentBlock.
# `sections` are repeating lists (page, section) stored as ContentItem rows.
# Values may contain simple HTML — they are rendered raw (admin-only content).
module PageContent
  # Extra per-item fields (beyond title/body) are stored in ContentItem#meta.
  ItemField = Struct.new(:name, :label, :meta, keyword_init: true)
  TITLE = ItemField.new(name: "title", label: "Title", meta: false)
  BODY  = ItemField.new(name: "body",  label: "Description", meta: false)
  def self.link_field = ItemField.new(name: "path", label: "Link (URL path)", meta: true)

  PAGES = {
    "home" => {
      label: "Home",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "AktiveSolutions builds fast, SEO-ready websites, web apps and mobile apps for businesses in Bicol and across the Philippines. Get a free project quote today." },
        { key: "hero_eyebrow", label: "Hero eyebrow", type: :text,
          default: "Web &amp; Mobile App Development · Philippines" },
        { key: "hero_heading", label: "Hero heading", type: :text,
          default: "Software that grows your business — built in the Philippines." },
        { key: "hero_body", label: "Hero paragraph", type: :textarea,
          default: "We design and develop high-performance websites, web apps and mobile apps for startups and SMEs in <strong class=\"text-white\">Bicol</strong> and nationwide. Clean code, on-time delivery, and results you can measure." },
        { key: "hero_cta_primary", label: "Hero primary button", type: :text, default: "Get a Free Quote" },
        { key: "hero_cta_secondary", label: "Hero secondary button", type: :text, default: "View Our Services" },
        { key: "services_eyebrow", label: "Services eyebrow", type: :text, default: "What we do" },
        { key: "services_heading", label: "Services heading", type: :text, default: "End-to-end product development" },
        { key: "services_body", label: "Services intro", type: :textarea,
          default: "From a marketing site to a full mobile app, we handle design, build and launch." },
        { key: "whyus_eyebrow", label: "Why-us eyebrow", type: :text, default: "Why AktiveSolutions" },
        { key: "whyus_heading", label: "Why-us heading", type: :text, default: "A local partner that ships quality" },
        { key: "whyus_body", label: "Why-us paragraph", type: :textarea,
          default: "Work directly with the developers building your product — no middlemen, no outsourcing surprises. We combine world-class engineering with local understanding of the Philippine market." },
        { key: "whyus_card_heading", label: "Why-us card heading", type: :text, default: "Ready to start your project?" },
        { key: "whyus_card_body", label: "Why-us card text", type: :textarea,
          default: "Tell us what you're building and we'll get back to you with a free, no-obligation quote." },
        { key: "whyus_card_cta", label: "Why-us card button", type: :text, default: "Get a Free Quote" }
      ],
      sections: [
        { key: "hero_stats", label: "Hero stats", fields: [TITLE, BODY],
          default: [
            { title: "Web",    body: "Sites &amp; web apps" },
            { title: "Mobile", body: "iOS &amp; Android" },
            { title: "SEO",    body: "Built to rank" }
          ] },
        { key: "services_cards", label: "Service cards", fields: [TITLE, BODY, link_field],
          default: [
            { title: "Web Development", body: "Marketing sites, dashboards and web apps built with modern, maintainable code.", meta: { "path" => "/services/web-development" } },
            { title: "Mobile Apps", body: "Native and cross-platform iOS &amp; Android apps your customers will love.", meta: { "path" => "/services/mobile-app-development" } },
            { title: "SEO &amp; Growth", body: "Technical SEO and content that helps Philippine businesses get found on Google.", meta: { "path" => "/services" } }
          ] },
        { key: "whyus_points", label: "Why-us points", fields: [TITLE, BODY],
          default: [
            { title: "Based in Bicol, serving the Philippines", body: "Local time zone, local context, easy to reach." },
            { title: "Built for performance &amp; SEO", body: "Fast, mobile-first, and structured to rank on Google." },
            { title: "Transparent, fixed-scope quotes", body: "Know what you're paying before we start." }
          ] }
      ]
    }
  }.freeze

  module_function

  def page(page)
    PAGES[page]
  end

  def page_labels
    PAGES.transform_values { |c| c[:label] }
  end

  def block_config(page, key)
    page(page)&.dig(:blocks)&.find { |b| b[:key] == key }
  end

  def section_config(page, section)
    page(page)&.dig(:sections)&.find { |s| s[:key] == section }
  end

  def default_block(page, key)
    block_config(page, key)&.fetch(:default, nil)
  end

  def default_items(page, section)
    (section_config(page, section)&.fetch(:default, []) || []).map do |h|
      ContentItem::Default.new(title: h[:title], body: h[:body], meta: (h[:meta] || {}))
    end
  end
end
