# frozen_string_literal: true

class Lead < ApplicationRecord
  # Pipeline stages. `new_lead` avoids clashing with ActiveRecord's `new`.
  enum :status, { new_lead: 0, contacted: 1, qualified: 2, won: 3, lost: 4 }

  PROJECT_TYPES = ["Website", "Web App", "Mobile App", "E-commerce", "SEO / Growth", "Other"].freeze
  BUDGET_RANGES = ["Under ₱50k", "₱50k – ₱150k", "₱150k – ₱500k", "₱500k+", "Not sure yet"].freeze
  TIMELINES     = ["ASAP", "Within 1–3 months", "3–6 months", "Just exploring"].freeze

  STATUS_LABELS = {
    "new_lead" => "New", "contacted" => "Contacted", "qualified" => "Qualified",
    "won" => "Won", "lost" => "Lost"
  }.freeze

  validates :name,    presence: true, length: { maximum: 120 }
  validates :email,   presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 5000 }
  validates :project_type, inclusion: { in: PROJECT_TYPES }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }

  def display_name
    name.presence || email
  end

  def status_label
    STATUS_LABELS[status] || status.to_s.humanize
  end
end
