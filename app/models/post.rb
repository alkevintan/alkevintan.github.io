# frozen_string_literal: true

class Post < ApplicationRecord
  include Sluggable

  has_rich_text :body
  has_one_attached :og_image

  enum :status, { draft: 0, published: 1 }

  validates :title,   presence: true, length: { maximum: 160 }
  validates :excerpt, presence: true, length: { maximum: 300 }

  scope :live,   -> { published.where(published_at: ..Time.current) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }

  before_save :ensure_published_at, :compute_reading_minutes

  # Used by the sitemap controller.
  def self.published_for_sitemap = live

  def meta_title_or_default
    meta_title.presence || title
  end

  def meta_description_or_default
    meta_description.presence || excerpt
  end

  def tag_list
    tags.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def related(limit: 3)
    self.class.live.where(category: category).where.not(id: id).recent.limit(limit)
  end

  private

  def ensure_published_at
    self.published_at ||= Time.current if published?
  end

  def compute_reading_minutes
    words = body.to_plain_text.split.size
    self.reading_minutes = [(words / 200.0).ceil, 1].max
  end
end
