# frozen_string_literal: true

# Per-page SEO metadata. Call `set_meta` at the top of a view (or from a
# controller via a @page_meta hash) and the layout's <head> renders the rest.
#
#   <% set_meta title: "Web Development", description: "…", image: "…" %>
#
module MetaTagsHelper
  # Store page-level overrides. Everything is optional; sensible sitewide
  # defaults from SITE fill the gaps.
  def set_meta(title: nil, description: nil, image: nil, canonical: nil,
               type: "website", noindex: false)
    page_meta.merge!(
      title: title,
      description: description,
      image: image,
      canonical: canonical,
      type: type,
      noindex: noindex
    ).compact
    nil
  end

  def page_meta
    @page_meta ||= { type: "website", noindex: false }
  end

  # "<Page> · AktiveSolutions" on inner pages, brand + tagline on the home page.
  def meta_title
    if page_meta[:title].present?
      "#{page_meta[:title]} · #{SITE[:name]}"
    else
      "#{SITE[:name]} — #{SITE[:tagline]}"
    end
  end

  def meta_description
    page_meta[:description].presence || SITE[:description]
  end

  # Canonical URL forced to the production domain + https, query string stripped.
  def meta_canonical
    page_meta[:canonical].presence || absolute_url(request.path)
  end

  def meta_image
    absolute_url(page_meta[:image].presence || SITE[:default_og_image])
  end

  def meta_noindex?
    page_meta[:noindex] || !Rails.env.production?
  end

  # Build an absolute https URL on the canonical domain from a path or filename.
  def absolute_url(path_or_file)
    return path_or_file if path_or_file.to_s.start_with?("http")

    path = path_or_file.to_s.start_with?("/") ? path_or_file : "/#{path_or_file}"
    "#{SITE[:url]}#{path}"
  end
end
