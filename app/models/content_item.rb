# frozen_string_literal: true

# One entry in a repeating page section (hero stats, why-us points, service
# cards, process steps, tech tags, …). `meta` holds section-specific extras
# such as a link path. Falls back to PageContent registry defaults.
class ContentItem < ApplicationRecord
  validates :page,    presence: true
  validates :section, presence: true

  scope :published,   -> { where(published: true) }
  scope :for_section, ->(page, section) { where(page: page, section: section) }
  scope :ordered,     -> { order(:position, :id) }

  # Lightweight stand-in used for registry defaults so views can treat defaults
  # and DB rows through the same title/body/meta interface.
  Default = Struct.new(:title, :body, :meta, keyword_init: true) do
    def meta = self[:meta] || {}
  end
end
