# frozen_string_literal: true

# Dynamic XML sitemap. Lists the static marketing pages plus any published
# blog posts / case studies once those models exist.
class SitemapsController < ApplicationController
  def index
    @entries = static_entries + dynamic_entries
    respond_to { |format| format.xml { render layout: false } }
  end

  private

  # [path, changefreq, priority]
  def static_entries
    [
      ["/", "weekly", "1.0"],
      [services_path, "monthly", "0.9"],
      [web_development_path, "monthly", "0.9"],
      [mobile_development_path, "monthly", "0.9"],
      [portfolio_path, "monthly", "0.7"],
      [about_path, "monthly", "0.6"],
      [contact_path, "yearly", "0.8"],
      [blog_path, "weekly", "0.7"],
      [privacy_path, "yearly", "0.2"],
      [terms_path, "yearly", "0.2"]
    ].map { |path, freq, pri| { loc: absolute(path), changefreq: freq, priority: pri } }
  end

  def dynamic_entries
    entries = []
    if defined?(Post) && Post.table_exists?
      Post.respond_to?(:published) && Post.published.find_each do |post|
        entries << { loc: absolute(blog_post_path(post)), lastmod: post.updated_at.iso8601,
                     changefreq: "monthly", priority: "0.6" }
      end
    end
    if defined?(CaseStudy) && CaseStudy.table_exists?
      CaseStudy.find_each do |cs|
        entries << { loc: absolute(portfolio_item_path(cs)), lastmod: cs.updated_at.iso8601,
                     changefreq: "yearly", priority: "0.5" }
      end
    end
    entries
  rescue StandardError
    []
  end

  def absolute(path)
    "#{SITE[:url]}#{path}"
  end
end
