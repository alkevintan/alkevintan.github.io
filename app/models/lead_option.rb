# frozen_string_literal: true

# Editable option for a contact-form dropdown (project type / budget / timeline).
# The `label` is both the shown text and the value stored on the Lead.
class LeadOption < ApplicationRecord
  FIELD_LABELS = {
    "project_type" => "Project type",
    "budget_range" => "Budget range",
    "timeline"     => "Timeline"
  }.freeze

  validates :field, presence: true
  validates :label, presence: true

  scope :published, -> { where(published: true) }
  scope :for_field, ->(field) { where(field: field) }
  scope :ordered,   -> { order(:position, :id) }

  def field_label
    FIELD_LABELS.fetch(field, field.to_s.humanize)
  end

  # Built-in defaults mirror the original Lead constants.
  DEFAULTS = {
    "project_type" => Lead::PROJECT_TYPES,
    "budget_range" => Lead::BUDGET_RANGES,
    "timeline"     => Lead::TIMELINES
  }.freeze

  # Option labels for a field: published DB rows, else the built-in defaults.
  def self.values_for(field)
    published.for_field(field).ordered.pluck(:label).presence || DEFAULTS.fetch(field, [])
  end
end
