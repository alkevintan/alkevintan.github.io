# frozen_string_literal: true

# The `services` page "we also help with" cards now link to dedicated service
# pages (SEO, e-commerce, UI/UX, maintenance). Rows seeded before those pages
# existed have no `meta["path"]`, so back-fill it here by title. Idempotent.
class BackfillServiceExtraLinks < ActiveRecord::Migration[8.1]
  PATHS = {
    "SEO &amp; Growth"         => "/services/seo",
    "E-commerce"               => "/services/e-commerce",
    "UI/UX Design"             => "/services/ui-ux-design",
    "Maintenance &amp; Support" => "/services/maintenance"
  }.freeze

  class MigrationContentItem < ActiveRecord::Base
    self.table_name = "content_items"
  end

  def up
    MigrationContentItem.where(page: "services", section: "extras").find_each do |item|
      path = PATHS[item.title]
      next if path.nil? || item.meta["path"].present?

      item.update_columns(meta: item.meta.merge("path" => path))
    end

    # The home page "SEO & Growth" card previously pointed at the generic
    # /services index; repoint it at the new dedicated SEO page.
    MigrationContentItem.where(page: "home", section: "services_cards").find_each do |item|
      next unless item.title == "SEO &amp; Growth" && item.meta["path"] == "/services"

      item.update_columns(meta: item.meta.merge("path" => "/services/seo"))
    end
  end

  def down
    MigrationContentItem.where(page: "services", section: "extras").find_each do |item|
      next if item.meta["path"].blank?

      item.update_columns(meta: item.meta.except("path"))
    end

    MigrationContentItem.where(page: "home", section: "services_cards").find_each do |item|
      next unless item.title == "SEO &amp; Growth" && item.meta["path"] == "/services/seo"

      item.update_columns(meta: item.meta.merge("path" => "/services"))
    end
  end
end
