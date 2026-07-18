# frozen_string_literal: true

# Generates a URL-friendly slug from a source attribute (default: `title`)
# and guarantees uniqueness. Include and optionally override `slug_source`.
module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: -> { slug.blank? && slug_source.present? }
    validates :slug, presence: true, uniqueness: true,
      format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                message: "must be lowercase letters, numbers and hyphens" }
  end

  # Pretty URLs: /blog/my-post-slug instead of /blog/123
  def to_param
    slug
  end

  private

  def slug_source
    title
  end

  def generate_slug
    base = slug_source.to_s.parameterize
    candidate = base
    n = 2
    while self.class.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end
end
