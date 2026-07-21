module ApplicationHelper
  # FAQ pairs for a page: editable rows when present, else the built-in defaults
  # so the section never disappears before the table is seeded.
  def faqs_for(page)
    rows = Faq.published.for_page(page).ordered
    return Faq::DEFAULTS.fetch(page, []) if rows.blank?

    rows.map { |f| [f.question, f.answer] }
  end

  # Editable singular copy field as a plain string (DB value or registry default).
  def content_text(page, key)
    (ContentBlock.value_for(page, key).presence || PageContent.default_block(page, key)).to_s
  end

  # Same, rendered raw for in-page copy (admin-only content may include HTML).
  def content_block(page, key)
    raw(content_text(page, key))
  end

  # Editable repeating section. Returns published DB rows, else registry
  # defaults — both expose .title/.body/.meta so views iterate uniformly.
  def content_items(page, section)
    rows = ContentItem.published.for_section(page, section).ordered
    rows.any? ? rows.to_a : PageContent.default_items(page, section)
  end
end
