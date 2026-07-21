module ApplicationHelper
  # FAQ pairs for a page: editable rows when present, else the built-in defaults
  # so the section never disappears before the table is seeded.
  def faqs_for(page)
    rows = Faq.published.for_page(page).ordered
    return Faq::DEFAULTS.fetch(page, []) if rows.blank?

    rows.map { |f| [f.question, f.answer] }
  end
end
