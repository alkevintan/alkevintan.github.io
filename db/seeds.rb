# frozen_string_literal: true

# Idempotent seeds: an admin user + sample marketing content.
# Run with: bin/rails db:seed

# ---------------------------------------------------------------------------
# Admin user
# ---------------------------------------------------------------------------
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@aktivesolutions.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password")

admin = User.find_or_initialize_by(email_address: admin_email)
if admin.new_record?
  admin.password = admin_password
  admin.save!
  puts "Created admin user: #{admin_email}"
else
  puts "Admin user already exists: #{admin_email}"
end

# ---------------------------------------------------------------------------
# Site settings (single row, pre-filled from the built-in defaults)
# ---------------------------------------------------------------------------
if SiteSetting.none?
  d = SITE_DEFAULTS
  SiteSetting.create!(
    name: d[:name], legal_name: d[:legal_name], tagline: d[:tagline],
    description: d[:description], domain: d[:domain], url: d[:url], locale: d[:locale],
    email: d[:email], phone: d[:phone], phone_link: d[:phone_link], whatsapp: d[:whatsapp],
    address_locality: d[:address][:locality], address_region: d[:address][:region],
    address_area: d[:address][:area], address_country: d[:address][:country],
    address_country_name: d[:address][:country_name],
    service_areas: d[:service_areas].join("\n"),
    facebook_url: d[:social][:facebook], linkedin_url: d[:social][:linkedin],
    instagram_url: d[:social][:instagram], github_url: d[:social][:github],
    ga4_measurement_id: d[:ga4_measurement_id],
    google_site_verification: d[:google_site_verification],
    default_og_image: d[:default_og_image]
  )
  puts "Created site settings row"
else
  puts "Site settings already present"
end

# ---------------------------------------------------------------------------
# Page content (blocks + repeating items, seeded from the PageContent registry)
# ---------------------------------------------------------------------------
PageContent::PAGES.each do |page, cfg|
  cfg[:blocks].each do |block|
    cb = ContentBlock.find_or_initialize_by(page: page, key: block[:key])
    cb.content = block[:default] if cb.new_record?
    cb.save!
  end

  cfg[:sections].each do |section|
    next if ContentItem.for_section(page, section[:key]).exists?

    PageContent.default_items(page, section[:key]).each_with_index do |d, i|
      ContentItem.create!(page: page, section: section[:key],
                          title: d.title, body: d.body, meta: d.meta,
                          position: i, published: true)
    end
  end
end
puts "Content blocks: #{ContentBlock.count}, items: #{ContentItem.count}"

# ---------------------------------------------------------------------------
# Menu links (header + footer columns), seeded from the built-in defaults
# ---------------------------------------------------------------------------
MenuItem::DEFAULTS.each do |menu, links|
  links.each_with_index do |(label, url), i|
    item = MenuItem.find_or_initialize_by(menu: menu, label: label, url: url)
    item.position = i
    item.published = true if item.new_record?
    item.save!
  end
end
puts "Menu items: #{MenuItem.count}"

# ---------------------------------------------------------------------------
# FAQs (seeded from the built-in defaults, then editable in the admin)
# ---------------------------------------------------------------------------
Faq::DEFAULTS.each do |page, pairs|
  pairs.each_with_index do |(question, answer), i|
    faq = Faq.find_or_initialize_by(page: page, question: question)
    faq.answer = answer
    faq.position = i
    faq.published = true if faq.new_record?
    faq.save!
  end
end
puts "FAQs: #{Faq.count}"

# ---------------------------------------------------------------------------
# Testimonials
# ---------------------------------------------------------------------------
[
  { author_name: "Maria Santos", role: "Owner", company: "Santos Boutique, Naga City",
    quote: "AktiveSolutions built our online store and we started getting orders from all over Bicol within weeks. Professional, fast, and easy to work with.",
    rating: 5, featured: true, position: 1 },
  { author_name: "Jomar Reyes", role: "Founder", company: "TourLegazpi",
    quote: "They turned our booking idea into a real mobile app. Communication was clear the whole time and they delivered on schedule.",
    rating: 5, featured: true, position: 2 },
  { author_name: "Ana Villanueva", role: "Marketing Head", company: "Camarines Agri Co-op",
    quote: "Our new website finally shows up on Google when people search for us. Traffic and inquiries are up. Highly recommended.",
    rating: 5, featured: true, position: 3 }
].each do |attrs|
  t = Testimonial.find_or_initialize_by(author_name: attrs[:author_name], company: attrs[:company])
  t.update!(attrs)
end
puts "Testimonials: #{Testimonial.count}"

# ---------------------------------------------------------------------------
# Case studies
# ---------------------------------------------------------------------------
case_studies = [
  {
    title: "E-commerce store for a Naga City boutique",
    slug: "naga-city-boutique-ecommerce",
    client: "Santos Boutique", industry: "Retail / Fashion",
    tech_stack: "Ruby on Rails, Hotwire, Stripe, PostgreSQL",
    results: "3x more orders in the first quarter; now shipping nationwide.",
    summary: "A fast, mobile-first online store that let a local boutique sell beyond their physical shop.",
    featured: true, published: true, position: 1,
    body: "<h2>The challenge</h2><p>Santos Boutique had a loyal walk-in following in Naga City but no way to sell online. They needed a store that was easy to manage and quick on mobile, where most of their customers browse.</p><h2>What we built</h2><p>We designed and developed a custom e-commerce store with product management, secure card payments, and nationwide shipping options. The site is optimized for speed and SEO so it ranks for local searches.</p><h2>The result</h2><p>Within the first quarter, online orders tripled and the boutique began shipping to customers across the Philippines.</p>"
  },
  {
    title: "Booking app for a Legazpi tour operator",
    slug: "legazpi-tour-operator-booking-app",
    client: "TourLegazpi", industry: "Travel / Tourism",
    tech_stack: "React Native, Rails API, PostgreSQL",
    results: "Bookings handled 24/7 without manual back-and-forth.",
    summary: "A cross-platform mobile app that lets travelers book Mayon-area tours in a few taps.",
    featured: true, published: true, position: 2,
    body: "<h2>The challenge</h2><p>TourLegazpi was managing bookings over Facebook Messenger and spreadsheets, which didn't scale during peak season.</p><h2>What we built</h2><p>We built a cross-platform iOS and Android app with real-time availability, online booking, and automated confirmations, backed by a Rails API.</p><h2>The result</h2><p>Travelers can now book tours any time of day, and the team spends far less time on manual coordination.</p>"
  }
]
case_studies.each do |attrs|
  body = attrs.delete(:body)
  cs = CaseStudy.find_or_initialize_by(slug: attrs[:slug])
  cs.assign_attributes(attrs)
  cs.body = body
  cs.save!
end
puts "Case studies: #{CaseStudy.count}"

# ---------------------------------------------------------------------------
# Blog posts (SEO cornerstone content)
# ---------------------------------------------------------------------------
posts = [
  {
    title: "How Much Does a Website Cost in the Philippines? (2026 Guide)",
    slug: "website-cost-philippines-2026",
    category: "Web Development",
    tags: "pricing, websites, philippines",
    excerpt: "A clear breakdown of what a website really costs in the Philippines in 2026 — from simple brochure sites to custom web apps — and what drives the price.",
    meta_description: "How much does a website cost in the Philippines in 2026? A transparent breakdown of pricing for brochure sites, business sites, e-commerce and web apps.",
    author: "AktiveSolutions", status: :published,
    body: "<p>One of the first questions Filipino business owners ask is: <strong>how much does a website cost?</strong> The honest answer is that it depends on what you need. Below is a realistic guide for 2026.</p><h2>Brochure & business websites</h2><p>A professional multi-page website for a small business typically ranges from ₱30,000 to ₱120,000 depending on design, content, and features like a blog or contact forms.</p><h2>E-commerce websites</h2><p>Online stores that accept payments and manage inventory generally start around ₱150,000 and go up based on catalog size and integrations.</p><h2>Custom web applications</h2><p>Booking systems, dashboards, and other custom software are quoted per project after we understand your requirements.</p><h2>What drives the price</h2><ul><li>Design complexity and custom branding</li><li>Number of pages and amount of content</li><li>Features: payments, bookings, user accounts</li><li>SEO and performance optimization</li></ul><p>Want an exact number for your project? <a href=\"/contact\">Get a free quote</a> and we'll give you a fixed-scope estimate.</p>"
  },
  {
    title: "How to Choose a Web Development Company in Bicol",
    slug: "choose-web-development-company-bicol",
    category: "Business",
    tags: "hiring, bicol, agencies",
    excerpt: "Hiring a web developer in Bicol? Here's what to look for — from portfolio and communication to SEO know-how — so you get a site that actually grows your business.",
    meta_description: "A practical checklist for choosing a web development company in Bicol (Naga, Legazpi and beyond) that delivers quality work on time.",
    author: "AktiveSolutions", status: :published,
    body: "<p>Choosing the right development partner is the difference between a website that works for you and one that collects dust. Here's what to check.</p><h2>1. Look at real work</h2><p>Ask for a portfolio and, ideally, live sites you can visit. Speed and mobile experience tell you a lot.</p><h2>2. Ask who you'll actually talk to</h2><p>Working directly with the developers — not layers of middlemen — means clearer communication and fewer surprises.</p><h2>3. Check for SEO and performance</h2><p>A beautiful site that doesn't rank on Google won't bring you customers. Make sure your partner builds for search and speed from the start.</p><h2>4. Get a clear, fixed scope</h2><p>Know what you're paying for before work begins. Transparent, fixed-scope quotes protect both sides.</p><p><a href=\"/contact\">Talk to us</a> about your project — we're based in Bicol and serve clients nationwide.</p>"
  },
  {
    title: "Do You Need a Mobile App or a Website for Your Business?",
    slug: "mobile-app-vs-website-philippines",
    category: "Mobile Apps",
    tags: "mobile, strategy, websites",
    excerpt: "Not sure whether to invest in a mobile app or a website first? This guide helps Philippine business owners decide based on goals, budget, and customers.",
    meta_description: "Mobile app vs website: which does your Philippine business need first? A simple framework to decide based on your goals and budget.",
    author: "AktiveSolutions", status: :published,
    body: "<p>Should you build a mobile app or a website? For most businesses, the answer is a website first — but not always. Here's how to decide.</p><h2>Start with a website if…</h2><ul><li>You need to be found on Google</li><li>You want to showcase products or services</li><li>Budget is a key concern</li></ul><h2>Consider a mobile app if…</h2><ul><li>You need push notifications or offline features</li><li>Customers will use your service repeatedly (bookings, loyalty, delivery)</li><li>You want a presence on the App Store and Google Play</li></ul><h2>Or do both</h2><p>Many businesses start with a strong website and add an app once there's proven demand. We can help you plan the right sequence.</p><p><a href=\"/contact\">Get a free consultation</a> and we'll recommend the best path for your goals.</p>"
  }
]
posts.each do |attrs|
  body = attrs.delete(:body)
  post = Post.find_or_initialize_by(slug: attrs[:slug])
  post.assign_attributes(attrs)
  post.body = body
  post.published_at ||= Time.current
  post.save!
end
puts "Posts: #{Post.count}"

puts "Seeding complete."
