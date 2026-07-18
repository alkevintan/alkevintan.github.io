# frozen_string_literal: true

class CaseStudy < ApplicationRecord
  include Sluggable

  has_rich_text :body
  has_one_attached :cover_image

  validates :title, presence: true, length: { maximum: 160 }
  validates :summary, presence: true

  scope :live,     -> { where(published: true) }
  scope :featured, -> { where(featured: true) }
  scope :ordered,  -> { order(position: :asc, created_at: :desc) }

  def tech_list
    tech_stack.to_s.split(",").map(&:strip).reject(&:blank?)
  end
end
