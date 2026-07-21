# frozen_string_literal: true

# An accordion FAQ entry shown on a marketing page (services / web / mobile).
# `answer` may contain simple HTML (links) — rendered raw by shared/_faq.
class Faq < ApplicationRecord
  # Pages that render an FAQ section, with human labels for the admin UI.
  PAGE_LABELS = {
    "services"           => "Services",
    "web_development"    => "Web Development",
    "mobile_development" => "Mobile App Development"
  }.freeze

  validates :page,     presence: true
  validates :question, presence: true
  validates :answer,   presence: true

  scope :published, -> { where(published: true) }
  scope :for_page,  ->(page) { where(page: page) }
  scope :ordered,   -> { order(:position, :id) }

  def page_label
    PAGE_LABELS.fetch(page, page.to_s.humanize)
  end

  # Built-in fallback content — mirrors what the pages showed before FAQs became
  # editable. Used to seed the table and as a safety net when no rows exist.
  DEFAULTS = {
    "services" => [
      ["Where are you based, and do you work remotely?",
       "We're based in the Bicol Region (Naga / Legazpi area) and work with clients across the Philippines, communicating online throughout the project."],
      ["How do your quotes work?",
       "We give fixed-scope quotes after a short discovery chat, so you know the cost up front with no surprises. <a href='/contact'>Request a free quote</a>."],
      ["What size businesses do you work with?",
       "Mostly startups and small-to-medium businesses (SMEs), but we're happy to help organizations of any size."]
    ],
    "web_development" => [
      ["How much does a website cost in the Philippines?",
       "It depends on scope. Business websites typically range from ₱30,000–₱120,000, while e-commerce and custom web apps are quoted per project. <a href='/blog/website-cost-philippines-2026'>Read our full pricing guide</a> or <a href='/contact'>get a free quote</a>."],
      ["How long does it take to build a website?",
       "A typical business website takes 3–6 weeks from kickoff to launch, depending on the number of pages and features."],
      ["Will my website show up on Google?",
       "Yes. We build every site with technical SEO, fast load times and clean structure so it can rank — and we can help with ongoing SEO content too."],
      ["Do you work with businesses outside Bicol?",
       "Absolutely. We're based in Bicol but work with clients across the Philippines and communicate online throughout the project."],
      ["Can you redesign my existing website?",
       "Yes. We can modernize a slow or outdated site while preserving your content and search rankings."]
    ],
    "mobile_development" => [
      ["Should I build a mobile app or a website first?",
       "It depends on your goals. Many businesses start with a website and add an app once there's proven demand. <a href='/blog/mobile-app-vs-website-philippines'>Read our guide</a> to decide."],
      ["Do you build for both iOS and Android?",
       "Yes. We usually build cross-platform apps so you reach both iOS and Android users from a single codebase, which saves time and cost."],
      ["How much does a mobile app cost in the Philippines?",
       "App projects are quoted based on features and complexity. Tell us your idea and we'll give you a fixed-scope estimate for free."],
      ["Will you help publish the app to the stores?",
       "Yes. We handle the builds, store listings and submission to the Apple App Store and Google Play."],
      ["Do you provide support after launch?",
       "Yes. We offer maintenance and support so your app stays updated and reliable as your business grows."]
    ]
  }.freeze
end
