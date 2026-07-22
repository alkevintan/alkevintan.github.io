# frozen_string_literal: true

require "base64"
require "json"

# SEO content CLI for AktiveSolutions — the programmatic equivalent of the
# /admin editor, built for the seo-assistant agent (and humans) to inspect and
# manage all SEO-relevant site content: editable page copy (ContentBlock /
# ContentItem via the PageContent registry), blog posts, and site settings
# (NAP / analytics / default meta).
#
# Booted through `bin/seo`, which runs it under `rails runner`, so the full
# Rails environment and all models are loaded and ARGV holds the subcommand.
# By default `bin/seo` targets the LIVE production site (running the CLI inside
# the deployed container via `kamal app exec`); `--local` targets the dev DB.
#
# Every command accepts `--json` for machine-readable output; without it you
# get compact human-readable text. Writes validate against the same registry
# the admin editor uses, so the agent can never create unknown keys/fields.
module Seo
  class CLI
    # Site-setting columns the CLI is allowed to write, grouped for `settings`
    # display. Everything here is a plain string/text column on site_settings.
    SETTING_GROUPS = {
      "Brand / SEO" => %w[name legal_name tagline description url domain locale default_og_image],
      "Contact (NAP)" => %w[email phone phone_link whatsapp
                            address_locality address_region address_area
                            address_country address_country_name service_areas],
      "Social" => %w[facebook_url linkedin_url instagram_url github_url],
      "Analytics / verification" => %w[ga4_measurement_id google_site_verification]
    }.freeze
    SETTING_FIELDS = SETTING_GROUPS.values.flatten.freeze

    POST_FIELDS = %w[title excerpt category tags author meta_title meta_description
                     status published_at slug body].freeze

    # Markers wrapped around stdout when running remotely (inside the prod
    # container via Kamal) so `bin/seo` can extract clean output from Kamal's
    # own connection chatter regardless of what it prints.
    MARK_BEGIN = "===SEO:BEGIN==="
    MARK_END   = "===SEO:END==="

    def self.run(argv)
      new(argv).run
    end

    def initialize(argv)
      # When dispatched into the prod container, `bin/seo` packs the real argv
      # (including any file contents) as base64 JSON so arbitrary text/HTML
      # survives every shell hop. Unpack it back into the normal argv here.
      if argv[0] == "--argv64"
        @remote = true
        argv = JSON.parse(Base64.strict_decode64(argv[1].to_s))
      end
      @json = argv.delete("--json") ? true : false
      @argv = argv
      @command = argv.shift
    end

    def run
      @failed = false
      puts MARK_BEGIN if @remote
      begin
        dispatch
      rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad => e
        fail_out("Cannot reach the #{@remote ? 'production' : Rails.env} database.\n  #{e.message}")
      rescue Aborted => e
        fail_out(e.message)
      ensure
        puts MARK_END if @remote
      end
      exit 1 if @failed
    end

    def dispatch
      case @command
      when "pages"            then cmd_pages
      when "show"            then cmd_show(@argv[0])
      when "get"             then cmd_get(@argv[0], @argv[1])
      when "set"             then cmd_set(@argv[0], @argv[1], @argv[2])
      when "reset"           then cmd_reset(@argv[0], @argv[1])
      when "items"           then cmd_items(@argv[0], @argv[1])
      when "settings"        then cmd_settings
      when "settings:set"    then cmd_settings_set(@argv[0], @argv[1])
      when "posts"           then cmd_posts
      when "post"            then cmd_post(@argv[0])
      when "post:new"        then cmd_post_new
      when "post:edit"       then cmd_post_edit(@argv.shift)
      when "post:publish"    then cmd_post_status(@argv[0], publish: true)
      when "post:unpublish"  then cmd_post_status(@argv[0], publish: false)
      when "post:delete"     then cmd_post_delete(@argv[0])
      when "audit"           then cmd_audit
      when "help", nil, "--help", "-h" then print_help
      else
        warn "Unknown command: #{@command.inspect}\n\n"
        print_help
        exit 1
      end
    end

    # ---------------------------------------------------------------- pages ---

    def cmd_pages
      pages = PageContent::PAGES.map do |slug, cfg|
        { page: slug, label: cfg[:label],
          blocks: cfg[:blocks].size, sections: cfg[:sections].size }
      end
      return emit(pages) if @json

      puts "Editable pages (#{pages.size}):"
      pages.each do |p|
        puts "  #{p[:page].ljust(20)} #{p[:label]}  (#{p[:blocks]} fields, #{p[:sections]} sections)"
      end
      puts "\nUse `seo show <page>` to see fields, `seo audit` for an SEO review."
    end

    def cmd_show(page)
      cfg = require_page(page)
      blocks = cfg[:blocks].map do |b|
        db = ContentBlock.value_for(page, b[:key])
        { key: b[:key], label: b[:label],
          value: db.presence || b[:default].to_s,
          source: db.present? ? "db" : "default" }
      end
      sections = cfg[:sections].map do |s|
        rows = ContentItem.for_section(page, s[:key]).ordered
        { section: s[:key], label: s[:label],
          count: rows.any? ? rows.size : PageContent.default_items(page, s[:key]).size,
          source: rows.any? ? "db" : "default" }
      end
      data = { page: page, label: cfg[:label], blocks: blocks, sections: sections }
      return emit(data) if @json

      puts "#{cfg[:label]} (#{page})\n\n"
      puts "FIELDS:"
      blocks.each do |b|
        puts "  [#{b[:source]}] #{b[:key]}  — #{b[:label]}"
        puts "        #{truncate(b[:value])}"
      end
      unless sections.empty?
        puts "\nSECTIONS:"
        sections.each { |s| puts "  [#{s[:source]}] #{s[:section]}  — #{s[:label]} (#{s[:count]} items). See `seo items #{page} #{s[:section]}`." }
      end
    end

    def cmd_get(page, key)
      require_page(page)
      cfg = PageContent.block_config(page, key) or abort_cmd("No such field '#{key}' on page '#{page}'. See `seo show #{page}`.")
      db = ContentBlock.value_for(page, key)
      data = { page: page, key: key, value: db.presence || cfg[:default].to_s,
               source: db.present? ? "db" : "default", default: cfg[:default].to_s }
      return emit(data) if @json

      puts data[:value]
    end

    def cmd_set(page, key, value)
      require_page(page)
      PageContent.block_config(page, key) or abort_cmd("No such field '#{key}' on page '#{page}'. See `seo show #{page}`.")
      abort_cmd("Missing value. Usage: seo set <page> <key> <value>") if value.nil?

      block = ContentBlock.find_or_initialize_by(page: page, key: key)
      block.update!(content: value.to_s)
      done({ page: page, key: key, value: value.to_s, saved: true }, "Saved #{page}/#{key}.")
    end

    def cmd_reset(page, key)
      require_page(page)
      PageContent.block_config(page, key) or abort_cmd("No such field '#{key}' on page '#{page}'.")
      deleted = ContentBlock.where(page: page, key: key).delete_all
      done({ page: page, key: key, reset: deleted.positive? },
           deleted.positive? ? "Reset #{page}/#{key} to its built-in default." : "#{page}/#{key} was already using the default.")
    end

    def cmd_items(page, section)
      require_page(page)
      cfg = PageContent.section_config(page, section) or abort_cmd("No such section '#{section}' on page '#{page}'. See `seo show #{page}`.")
      rows = ContentItem.for_section(page, section).ordered
      items =
        if rows.any?
          rows.map { |r| { id: r.id, title: r.title, body: r.body, meta: r.meta, source: "db" } }
        else
          PageContent.default_items(page, section).map { |d| { id: nil, title: d.title, body: d.body, meta: d.meta, source: "default" } }
        end
      data = { page: page, section: section, label: cfg[:label], items: items }
      return emit(data) if @json

      puts "#{cfg[:label]} — #{page}/#{section} (#{items.size} items):"
      items.each_with_index do |it, i|
        puts "  #{i + 1}. [#{it[:source]}] #{it[:title]}"
        puts "     #{truncate(it[:body])}" if it[:body].present?
        puts "     meta: #{it[:meta].to_json}" if it[:meta].present?
      end
      puts "\nSection items are edited in the /admin UI; the CLI is read-only for these."
    end

    # ------------------------------------------------------------- settings ---

    def cmd_settings
      s = SiteSetting.current
      groups = SETTING_GROUPS.transform_values do |fields|
        fields.map do |f|
          raw = s.public_send(f)
          { field: f, value: raw.to_s, blank: raw.blank? }
        end
      end
      return emit(groups) if @json

      groups.each do |group, fields|
        puts "#{group}:"
        fields.each do |f|
          flag = f[:blank] ? " (blank → default)" : ""
          puts "  #{f[:field].ljust(26)} #{truncate(f[:value], 70)}#{flag}"
        end
        puts
      end
      puts "Set with: seo settings:set <field> <value>"
    end

    def cmd_settings_set(field, value)
      abort_cmd("Unknown setting '#{field}'. Fields: #{SETTING_FIELDS.join(', ')}") unless SETTING_FIELDS.include?(field)
      abort_cmd("Missing value. Usage: seo settings:set <field> <value>") if value.nil?

      row = SiteSetting.for_edit
      row.update!(field => value.to_s)
      done({ field: field, value: value.to_s, saved: true }, "Saved site setting #{field}.")
    end

    # ---------------------------------------------------------------- posts ---

    def cmd_posts
      status = opts["status"] || "all"
      scope = Post.all
      scope = scope.where(status: status) unless status == "all"
      posts = scope.order(created_at: :desc).map { |p| post_summary(p) }
      return emit(posts) if @json

      puts "Blog posts (#{posts.size}, status=#{status}):"
      posts.each do |p|
        puts "  [#{p[:status]}] #{p[:slug]}"
        puts "        #{p[:title]}  · #{p[:category] || 'no category'} · #{p[:reading_minutes]}m"
      end
      puts "\n`seo post <slug>` for detail, `seo post:new --title=...` to draft."
    end

    def cmd_post(slug)
      p = find_post(slug)
      data = post_summary(p).merge(
        excerpt: p.excerpt, meta_title: p.meta_title, meta_description: p.meta_description,
        tags: p.tag_list, author: p.author, published_at: p.published_at&.iso8601,
        body_html: p.body.to_s, body_text: p.body.to_plain_text, word_count: p.body.to_plain_text.split.size
      )
      return emit(data) if @json

      puts "#{p.title}  [#{p.status}]"
      puts "slug:        #{p.slug}"
      puts "category:    #{p.category}   tags: #{p.tag_list.join(', ')}"
      puts "meta_title:  #{p.meta_title_or_default}  (#{p.meta_title_or_default.length} chars)"
      puts "meta_descr:  #{p.meta_description_or_default}  (#{p.meta_description_or_default.length} chars)"
      puts "reading:     #{p.reading_minutes}m · #{data[:word_count]} words · published_at #{p.published_at}"
      puts "\nEXCERPT:\n  #{p.excerpt}"
      puts "\nBODY (text):\n#{p.body.to_plain_text}"
    end

    def cmd_post_new
      attrs = post_attrs_from_opts
      abort_cmd("--title is required") if attrs[:title].blank?
      abort_cmd("--excerpt is required (used as the meta description fallback)") if attrs[:excerpt].blank?

      post = Post.new(attrs)
      post.status ||= "draft"
      post.save!
      done(post_summary(post), "Created draft '#{post.title}' → /blog/#{post.slug}")
    end

    def cmd_post_edit(slug)
      post = find_post(slug)
      attrs = post_attrs_from_opts
      abort_cmd("Nothing to update. Pass fields like --title= --excerpt= --body-file=") if attrs.empty?

      post.update!(attrs)
      done(post_summary(post), "Updated '#{post.title}'.")
    end

    def cmd_post_status(slug, publish:)
      post = find_post(slug)
      post.status = publish ? "published" : "draft"
      post.published_at ||= Time.current if publish
      post.save!
      done(post_summary(post), "#{publish ? 'Published' : 'Unpublished'} '#{post.title}'.")
    end

    def cmd_post_delete(slug)
      post = find_post(slug)
      post.destroy!
      done({ slug: slug, deleted: true }, "Deleted post '#{slug}'.")
    end

    # ---------------------------------------------------------------- audit ---

    def cmd_audit
      findings = []
      findings.concat(audit_pages)
      findings.concat(audit_posts)
      findings.concat(audit_settings)

      by_sev = findings.group_by { |f| f[:severity] }
      summary = { error: by_sev["error"].to_a.size, warning: by_sev["warning"].to_a.size, info: by_sev["info"].to_a.size }
      return emit({ summary: summary, findings: findings }) if @json

      puts "SEO audit — #{findings.size} findings (#{summary[:error]} errors, #{summary[:warning]} warnings, #{summary[:info]} info)\n\n"
      icon = { "error" => "✗", "warning" => "!", "info" => "·" }
      %w[error warning info].each do |sev|
        (by_sev[sev] || []).each { |f| puts "  #{icon[sev]} [#{f[:area]}] #{f[:message]}" }
      end
      puts "\nNo issues found. 🎉" if findings.empty?
    end

    private

    # --- audit checks ---

    # Recommended SEO lengths.
    META_DESC_MIN = 70
    META_DESC_MAX = 160
    TITLE_MAX = 60

    def audit_pages
      out = []
      seen_desc = {}
      PageContent::PAGES.each do |page, cfg|
        next unless cfg[:blocks].any? { |b| b[:key] == "meta_description" }

        desc = (ContentBlock.value_for(page, "meta_description").presence ||
                PageContent.default_block(page, "meta_description")).to_s
        if desc.blank?
          out << finding("error", "meta", "#{page}: meta description is empty")
        else
          out << finding("warning", "meta", "#{page}: meta description is #{desc.length} chars (aim #{META_DESC_MIN}–#{META_DESC_MAX})") unless desc.length.between?(META_DESC_MIN, META_DESC_MAX)
          key = desc.strip.downcase
          (seen_desc[key] ||= []) << page
        end
      end
      seen_desc.each_value do |pages|
        out << finding("warning", "meta", "Duplicate meta description on: #{pages.join(', ')}") if pages.size > 1
      end
      out
    end

    def audit_posts
      out = []
      published = Post.published
      out << finding("info", "blog", "No published blog posts yet — the blog is the main long-tail SEO lever.") if published.none?

      Post.all.find_each do |p|
        label = "post '#{p.slug}'"
        md = p.meta_description_or_default.to_s
        out << finding("warning", "blog", "#{label}: meta description #{md.length} chars (aim #{META_DESC_MIN}–#{META_DESC_MAX})") unless md.length.between?(META_DESC_MIN, META_DESC_MAX)
        mt = p.meta_title_or_default.to_s
        out << finding("warning", "blog", "#{label}: meta title #{mt.length} chars (keep ≤ #{TITLE_MAX})") if mt.length > TITLE_MAX
        out << finding("warning", "blog", "#{label}: no category set") if p.category.blank?
        out << finding("info",    "blog", "#{label}: no tags set") if p.tag_list.empty?
        words = p.body.to_plain_text.split.size
        out << finding("warning", "blog", "#{label}: thin content (#{words} words — aim 600+ for ranking)") if p.published? && words < 600
      end
      out
    end

    def audit_settings
      out = []
      s = SiteSetting.current.to_site_hash
      out << finding("error",   "settings", "GA4 measurement ID is not set — analytics tag is disabled") if s[:ga4_measurement_id].blank?
      out << finding("warning", "settings", "Google Search Console verification token is not set") if s[:google_site_verification].blank?
      out << finding("error",   "settings", "Phone number is still the placeholder (+63 000 000 0000)") if s[:phone].to_s.include?("000 000")
      out << finding("warning", "settings", "No social profiles set (used for footer + sameAs JSON-LD)") if s[:social].values.all?(&:blank?)
      out
    end

    def finding(severity, area, message)
      { severity: severity, area: area, message: message }
    end

    # --- shared helpers ---

    Aborted = Class.new(StandardError)

    def require_page(page)
      abort_cmd("Missing page. See `seo pages`.") if page.nil?
      PageContent.page(page) || abort_cmd("Unknown page '#{page}'. See `seo pages`.")
    end

    def find_post(slug)
      abort_cmd("Missing slug. See `seo posts`.") if slug.nil?
      Post.find_by(slug: slug) || abort_cmd("No post with slug '#{slug}'. See `seo posts`.")
    end

    # Long-form `--key value` / `--key=value` option parsing from remaining ARGV.
    def opts
      @opts ||= begin
        h = {}
        args = @argv.dup
        until args.empty?
          tok = args.shift
          next unless tok.start_with?("--")

          key, val = tok[2..].split("=", 2)
          val = args.shift if val.nil? && args.first && !args.first.start_with?("--")
          h[key] = val.nil? ? true : val
        end
        h
      end
    end

    # Build a Post attribute hash from CLI options, reading --body-file if given.
    def post_attrs_from_opts
      o = opts
      attrs = {}
      %w[title excerpt category tags author meta_title meta_description slug status].each do |f|
        attrs[f.to_sym] = o[f.tr("_", "-")] || o[f] if o.key?(f.tr("_", "-")) || o.key?(f)
      end
      if o["body-file"]
        path = o["body-file"]
        abort_cmd("--body-file not found: #{path}") unless File.exist?(path)
        attrs[:body] = File.read(path)
      elsif o["body"].is_a?(String)
        attrs[:body] = o["body"]
      end
      attrs
    end

    def post_summary(p)
      { slug: p.slug, title: p.title, status: p.status, category: p.category,
        reading_minutes: p.reading_minutes, updated_at: p.updated_at.iso8601 }
    end

    # --- output ---

    def emit(obj)
      puts JSON.pretty_generate(obj)
    end

    # Print a success line (human) or the data (json).
    def done(data, message)
      @json ? emit(data.merge(ok: true)) : puts("✓ #{message}")
    end

    def abort_cmd(msg)
      raise Aborted, msg
    end

    # Report a fatal error and flag a non-zero exit. Remote runs print to stdout
    # (so the message lands inside the markers `bin/seo` extracts); local runs
    # print to stderr.
    def fail_out(msg)
      text = "ERROR: #{msg}"
      @remote ? puts(text) : warn(text)
      @failed = true
    end

    def truncate(str, len = 100)
      s = str.to_s.gsub(/\s+/, " ").strip
      s.length > len ? "#{s[0, len]}…" : s
    end

    def print_help
      puts <<~HELP
        seo — SEO content manager for AktiveSolutions

        Page copy (editable marketing pages):
          seo pages                          List all editable pages
          seo show <page>                    Show a page's fields + sections (value + source)
          seo get <page> <key>               Print one field's current value
          seo set <page> <key> <value>       Set/override a field
          seo reset <page> <key>             Drop the override, revert to built-in default
          seo items <page> <section>         List a repeating section's items (read-only)

        Site settings (NAP / analytics / default meta):
          seo settings                       Show all SEO-relevant settings
          seo settings:set <field> <value>   Set one setting field

        Blog posts (primary long-tail SEO lever):
          seo posts [--status=draft|published|all]
          seo post <slug>                    Show a post in full
          seo post:new --title= --excerpt= [--category= --tags= --body-file= --meta-title= --meta-description= --status=]
          seo post:edit <slug> [--field=value ...]
          seo post:publish <slug> | seo post:unpublish <slug>
          seo post:delete <slug>

        SEO review:
          seo audit                          Scan pages, posts & settings for SEO issues

        Target: defaults to the LIVE production site (via `kamal app exec`).
          Add --local (or --dev) to target the local dev database instead.
        Add --json to any command for machine-readable output.
      HELP
    end
  end
end

Seo::CLI.run(ARGV)
