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
  def self.number_field = ItemField.new(name: "number", label: "Step number", meta: true)
  TAG = ItemField.new(name: "title", label: "Tag", meta: false)

  PAGES = {
    "global" => {
      label: "Global (header/footer)",
      blocks: [
        { key: "header_cta", label: "Header CTA button", type: :text, default: "Get a Quote" },
        { key: "footer_blurb", label: "Footer blurb", type: :textarea,
          default: "Web &amp; mobile app development for businesses in Bicol and across the Philippines." }
      ],
      sections: []
    },
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
    },

    "about" => {
      label: "About",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "AktiveSolutions is a web and mobile app development studio based in Bicol, Philippines, helping startups and SMEs build software that grows their business." },
        { key: "header_eyebrow", label: "Header eyebrow", type: :text, default: "Who we are" },
        { key: "header_title", label: "Header title", type: :text, default: "A software studio built for Philippine businesses" },
        { key: "header_subtitle", label: "Header subtitle", type: :textarea,
          default: "We're AktiveSolutions — a web and mobile app development team based in Bicol, working with clients across the Philippines." },
        { key: "story_heading", label: "Story heading", type: :text, default: "Our story" },
        { key: "story_body", label: "Story paragraphs (HTML)", type: :textarea,
          default: "<p>AktiveSolutions was founded on a simple belief: world-class software shouldn't only be available to big companies in Manila. Businesses everywhere — from Naga to Legazpi to the rest of the country — deserve fast, well-built websites and apps that actually help them grow.</p><p>We work directly with our clients, no middlemen and no outsourcing surprises. That means clearer communication, better results, and software you can rely on.</p>" }
      ],
      sections: [
        { key: "values", label: "Value cards", fields: [TITLE, BODY],
          default: [
            { title: "Quality first", body: "We write clean, maintainable code and sweat the details — performance, security and accessibility included." },
            { title: "Local, but nationwide", body: "Based in Bicol and proud of it. We serve clients across the Philippines and communicate online end-to-end." },
            { title: "Transparent &amp; fair", body: "Fixed-scope quotes and honest advice. You'll always know what you're paying for and why." }
          ] },
        { key: "stats", label: "Stat band", fields: [TITLE, BODY],
          default: [
            { title: "Web + Mobile", body: "Full-stack product development under one roof" },
            { title: "Bicol-based", body: "Serving Naga, Legazpi &amp; the whole Philippines" },
            { title: "SEO-first", body: "Every build is made to be found on Google" }
          ] }
      ]
    },

    "services" => {
      label: "Services",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "Web development, web apps, mobile apps and SEO for Philippine businesses. See how AktiveSolutions can help you build and grow — from Bicol, nationwide." },
        { key: "header_eyebrow", label: "Header eyebrow", type: :text, default: "What we do" },
        { key: "header_title", label: "Header title", type: :text, default: "Services" },
        { key: "header_subtitle", label: "Header subtitle", type: :textarea,
          default: "End-to-end design, development and growth for web and mobile — built for the Philippine market." },
        { key: "web_title", label: "Web card title", type: :text, default: "Web Development" },
        { key: "web_body", label: "Web card text", type: :textarea,
          default: "Marketing sites, e-commerce, dashboards and custom web apps — fast, secure and SEO-ready." },
        { key: "mobile_title", label: "Mobile card title", type: :text, default: "Mobile App Development" },
        { key: "mobile_body", label: "Mobile card text", type: :textarea,
          default: "Native and cross-platform iOS &amp; Android apps, from idea to the App Store and Google Play." },
        { key: "extras_heading", label: "Extras heading", type: :text, default: "We also help with" }
      ],
      sections: [
        { key: "extras", label: "Also help with", fields: [TITLE, BODY],
          default: [
            { title: "SEO &amp; Growth", body: "Rank on Google and turn traffic into leads." },
            { title: "E-commerce", body: "Sell online with secure payments and shipping." },
            { title: "UI/UX Design", body: "Clean, modern, mobile-first interfaces." },
            { title: "Maintenance &amp; Support", body: "Keep your site or app fast, secure and up to date." }
          ] }
      ]
    },

    "web_development" => {
      label: "Web Development",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "Custom web development in the Philippines — fast, SEO-ready websites and web apps. Serving Bicol (Naga, Legazpi) and businesses nationwide. Get a free quote." },
        { key: "header_eyebrow", label: "Header eyebrow", type: :text, default: "Services" },
        { key: "header_title", label: "Header title", type: :text, default: "Web Development" },
        { key: "header_subtitle", label: "Header subtitle", type: :textarea,
          default: "Fast, secure, SEO-ready websites and web applications for Philippine businesses — designed to turn visitors into customers." },
        { key: "intro", label: "Intro paragraphs (HTML)", type: :textarea,
          default: "<p>Your website is often the first impression a customer has of your business. We build websites and web applications that load fast, look great on every phone, and are structured to rank on Google — so the right people find you and take action.</p><p>Whether you're a startup in Naga, an established business in Legazpi, or serving customers across the Philippines, we design and develop the web presence your business deserves.</p>" },
        { key: "what_heading", label: "\"What we build\" heading", type: :text, default: "What we build" },
        { key: "process_heading", label: "Process heading", type: :text, default: "How we work" },
        { key: "tech_heading", label: "Tech heading", type: :text, default: "Technology we use" },
        { key: "tech_body", label: "Tech intro", type: :textarea,
          default: "We build on proven, modern tools chosen for speed, security and long-term maintainability." },
        { key: "cta_title", label: "CTA title", type: :text, default: "Ready to build your website?" }
      ],
      sections: [
        { key: "what_we_build", label: "What we build", fields: [TITLE, BODY],
          default: [
            { title: "Business &amp; brochure sites", body: "Professional multi-page websites that build trust and generate inquiries." },
            { title: "E-commerce stores", body: "Online shops with secure payments, inventory and nationwide shipping." },
            { title: "Web applications", body: "Custom dashboards, booking systems and internal tools built around your workflow." },
            { title: "Landing pages", body: "High-converting pages for campaigns and ads." },
            { title: "Website redesigns", body: "Modernize a slow or dated site into a fast, mobile-first experience." },
            { title: "SEO &amp; performance", body: "Technical SEO, Core Web Vitals and speed tuning so you rank and convert." }
          ] },
        { key: "process", label: "Process steps", fields: [number_field, TITLE, BODY],
          default: [
            { title: "Discover", body: "We learn your goals, audience and requirements, then give you a clear, fixed-scope quote.", meta: { "number" => "01" } },
            { title: "Design", body: "We design a clean, on-brand, mobile-first experience for your approval.", meta: { "number" => "02" } },
            { title: "Build", body: "We develop with modern, maintainable code — and keep you updated throughout.", meta: { "number" => "03" } },
            { title: "Launch &amp; grow", body: "We launch, set up analytics and SEO, and support you after go-live.", meta: { "number" => "04" } }
          ] },
        { key: "tech_tags", label: "Technology tags", fields: [TAG],
          default: [
            { title: "Ruby on Rails" }, { title: "Hotwire" }, { title: "JavaScript" }, { title: "Tailwind CSS" },
            { title: "PostgreSQL" }, { title: "React" }, { title: "Stripe" }, { title: "AWS / Cloud" }
          ] }
      ]
    },

    "contact" => {
      label: "Contact",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "Get a free quote for your web or mobile app project. Contact AktiveSolutions in Bicol, Philippines." },
        { key: "header_eyebrow", label: "Header eyebrow", type: :text, default: "Get in touch" },
        { key: "header_title", label: "Header title", type: :text, default: "Let's talk about your project" },
        { key: "header_subtitle", label: "Header subtitle", type: :textarea,
          default: "Tell us what you're building and we'll get back to you within one business day with a free, no-obligation quote." }
      ],
      sections: []
    },

    "mobile_development" => {
      label: "Mobile App Development",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "iOS and Android mobile app development in the Philippines. Native and cross-platform apps built by AktiveSolutions in Bicol, serving clients nationwide. Get a free quote." },
        { key: "header_eyebrow", label: "Header eyebrow", type: :text, default: "Services" },
        { key: "header_title", label: "Header title", type: :text, default: "Mobile App Development" },
        { key: "header_subtitle", label: "Header subtitle", type: :textarea,
          default: "Native and cross-platform iOS &amp; Android apps — from idea to the App Store and Google Play." },
        { key: "intro", label: "Intro paragraphs (HTML)", type: :textarea,
          default: "<p>Your customers live on their phones. A well-built mobile app puts your business in their pocket — with fast performance, offline access, and push notifications that bring them back.</p><p>We take your idea from concept to launch, building reliable apps that people actually enjoy using, backed by a solid, scalable server.</p>" },
        { key: "what_heading", label: "\"What we build\" heading", type: :text, default: "What we build" },
        { key: "process_heading", label: "Process heading", type: :text, default: "How we work" },
        { key: "tech_heading", label: "Tech heading", type: :text, default: "Technology we use" },
        { key: "tech_body", label: "Tech intro", type: :textarea,
          default: "We choose the right tools for your app's needs and budget." },
        { key: "cta_title", label: "CTA title", type: :text, default: "Have an app idea? Let's build it." }
      ],
      sections: [
        { key: "what_we_build", label: "What we build", fields: [TITLE, BODY],
          default: [
            { title: "Cross-platform apps", body: "One codebase for both iOS and Android — faster to build and easier to maintain." },
            { title: "Native apps", body: "Platform-specific apps when you need maximum performance and device features." },
            { title: "Booking &amp; ordering apps", body: "Let customers book, order and pay from their phone, 24/7." },
            { title: "Business &amp; internal apps", body: "Tools for your team — inventory, field work, reporting and more." },
            { title: "App backends &amp; APIs", body: "Secure, scalable servers and APIs that power your app." },
            { title: "App Store launch", body: "We handle builds, store listings and the submission process." }
          ] },
        { key: "process", label: "Process steps", fields: [number_field, TITLE, BODY],
          default: [
            { title: "Discover", body: "We define your app's core features and give you a clear, fixed-scope quote.", meta: { "number" => "01" } },
            { title: "Design", body: "We design intuitive screens and flows your users will love.", meta: { "number" => "02" } },
            { title: "Build &amp; test", body: "We develop and rigorously test on real devices.", meta: { "number" => "03" } },
            { title: "Launch &amp; support", body: "We publish to the App Store and Google Play, then support your app.", meta: { "number" => "04" } }
          ] },
        { key: "tech_tags", label: "Technology tags", fields: [TAG],
          default: [
            { title: "React Native" }, { title: "Swift (iOS)" }, { title: "Kotlin (Android)" }, { title: "Ruby on Rails API" },
            { title: "PostgreSQL" }, { title: "Firebase" }, { title: "Push notifications" }
          ] }
      ]
    },

    "privacy" => {
      label: "Privacy Policy",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "How AktiveSolutions collects and uses your information." },
        { key: "header_title", label: "Page title", type: :text, default: "Privacy Policy" },
        { key: "body", label: "Policy text (HTML)", type: :textarea,
          default: "<p>This is a placeholder privacy policy for AktiveSolutions. Replace with your finalized policy before launch. We collect the information you submit through our contact form (such as your name, email and message) solely to respond to your inquiry.</p><h2>Contact</h2><p>Questions about this policy? Email <a href=\"mailto:hello@aktivesolutions.com\">hello@aktivesolutions.com</a>.</p>" }
      ],
      sections: []
    },

    "terms" => {
      label: "Terms of Service",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "The terms governing use of the AktiveSolutions website." },
        { key: "header_title", label: "Page title", type: :text, default: "Terms of Service" },
        { key: "body", label: "Terms text (HTML)", type: :textarea,
          default: "<p>This is a placeholder terms-of-service page for AktiveSolutions. Replace with your finalized terms before launch.</p>" }
      ],
      sections: []
    },

    "thank_you" => {
      label: "Thank-you page",
      blocks: [
        { key: "meta_description", label: "SEO meta description", type: :textarea,
          default: "Thanks for reaching out to AktiveSolutions." },
        { key: "heading", label: "Heading", type: :text, default: "Thank you!" },
        { key: "body", label: "Message", type: :textarea,
          default: "We've received your message and will get back to you within one business day." },
        { key: "cta", label: "Button label", type: :text, default: "Back to home" }
      ],
      sections: []
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
