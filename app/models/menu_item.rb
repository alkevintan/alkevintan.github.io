# frozen_string_literal: true

# A navigation link in the header nav or a footer column. `url` is a plain path
# or absolute URL so admins can point links anywhere.
class MenuItem < ApplicationRecord
  MENU_LABELS = {
    "header"          => "Header navigation",
    "footer_company"  => "Footer — Company",
    "footer_services" => "Footer — Services"
  }.freeze

  validates :menu,  presence: true
  validates :label, presence: true
  validates :url,   presence: true

  scope :published, -> { where(published: true) }
  scope :for_menu,  ->(menu) { where(menu: menu) }
  scope :ordered,   -> { order(:position, :id) }

  def menu_label
    MENU_LABELS.fetch(menu, menu.to_s.humanize)
  end

  # Built-in defaults — the links the site shipped with. Used to seed the table
  # and as a fallback so navigation never empties before seeding.
  DEFAULTS = {
    "header" => [
      ["Services", "/services"], ["Portfolio", "/portfolio"], ["Blog", "/blog"],
      ["About", "/about"], ["Contact", "/contact"]
    ],
    "footer_company" => [
      ["Services", "/services"], ["Portfolio", "/portfolio"], ["Blog", "/blog"],
      ["About", "/about"], ["Contact", "/contact"]
    ],
    "footer_services" => [
      ["Web Development", "/services/web-development"],
      ["Mobile App Development", "/services/mobile-app-development"],
      ["Get a Free Quote", "/contact"]
    ]
  }.freeze
end
