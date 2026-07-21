# frozen_string_literal: true

module Admin
  # Page-centric editor for marketing-page copy. Reads the editable fields and
  # repeating sections from the PageContent registry and persists them as
  # ContentBlock / ContentItem rows.
  class ContentController < BaseController
    before_action :set_page, only: %i[edit update]

    def index
      @pages = PageContent.page_labels
    end

    def edit; end

    def update
      # Registry-driven dynamic structure; safe to permit wholesale because
      # save_* below only consume keys/sections/fields declared in the registry.
      content = params.fetch(:content, {}).permit!.to_h
      save_blocks(content["blocks"])
      save_sections(content["sections"])
      redirect_to edit_admin_content_path(@page), notice: "#{@config[:label]} content saved."
    end

    # --- form prefill helpers (used by the view) ---

    # Current value for a block field: DB value, else registry default.
    def block_value(key)
      ContentBlock.value_for(@page, key).presence || PageContent.default_block(@page, key)
    end
    helper_method :block_value

    # Rows to render for a section: existing DB rows (or registry defaults when
    # none exist yet), plus one blank row for adding.
    def items_for_form(section)
      rows = ContentItem.for_section(@page, section).ordered.to_a
      if rows.empty?
        rows = PageContent.default_items(@page, section).map do |d|
          ContentItem.new(page: @page, section: section, title: d.title, body: d.body, meta: d.meta)
        end
      end
      rows + [ContentItem.new(page: @page, section: section, meta: {})]
    end
    helper_method :items_for_form

    private

    def set_page
      @page = params[:page]
      @config = PageContent.page(@page)
      head :not_found unless @config
    end

    def save_blocks(blocks)
      return if blocks.blank?

      blocks.each do |key, value|
        next unless PageContent.block_config(@page, key) # ignore unknown keys

        ContentBlock.find_or_initialize_by(page: @page, key: key).update!(content: value.to_s)
      end
    end

    def save_sections(sections)
      return if sections.blank?

      sections.each do |section, rows|
        cfg = PageContent.section_config(@page, section)
        next unless cfg

        position = 0
        rows.values.each do |row|
          position = save_row(section, cfg, row, position)
        end
      end
    end

    # Upserts/destroys a single section row; returns the next position to use.
    def save_row(section, cfg, row, position)
      title = body = nil
      meta = {}
      cfg[:fields].each do |field|
        value = row[field.name].to_s
        if field.meta then meta[field.name] = value
        elsif field.name == "title" then title = value
        elsif field.name == "body" then body = value
        end
      end

      item = row["id"].present? ? ContentItem.find_by(id: row["id"], page: @page, section: section) : nil
      blank = [title, body, *meta.values].all?(&:blank?)

      if row["_destroy"] == "1" || (blank && item)
        item&.destroy
        return position
      end
      return position if blank

      item ||= ContentItem.new(page: @page, section: section)
      item.update!(title: title, body: body, meta: meta, position: position, published: true)
      position + 1
    end
  end
end
