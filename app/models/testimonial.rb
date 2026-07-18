# frozen_string_literal: true

class Testimonial < ApplicationRecord
  has_one_attached :avatar

  validates :author_name, presence: true
  validates :quote, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  scope :featured, -> { where(featured: true) }
  scope :ordered,  -> { order(position: :asc, created_at: :desc) }

  def initials
    author_name.to_s.split.map(&:first).first(2).join.upcase
  end
end
