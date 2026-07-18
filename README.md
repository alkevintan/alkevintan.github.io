# AktiveSolutions

SEO-focused lead-generation website for a software-development studio offering
**web and mobile app development** to businesses in the **Philippines** — with a
focus on the **Bicol region** (Naga, Legazpi, Sorsogon) and nationwide reach.

Built with **Ruby on Rails 8** (server-rendered for SEO), PostgreSQL, Hotwire and
Tailwind CSS. Deployed self-hosted on **westeros** and exposed via a **Cloudflare
Tunnel**.

## Features

- Marketing site: Home, Services (+ Web / Mobile detail pages), Portfolio (case
  studies), About, Contact, plus a **blog** for SEO content.
- **Lead capture** form (`/contact`) with honeypot + time-trap spam protection,
  stored in the database and emailed to the owner.
- **Admin dashboard** (`/admin`, auth-protected): leads pipeline + notes, and CRUD
  for blog posts, case studies and testimonials (rich text + image uploads).
- SEO built-in: per-page title/description/canonical, Open Graph + Twitter cards,
  JSON-LD (`ProfessionalService`, `Article`, `FAQPage`), dynamic `sitemap.xml`
  and `robots.txt`, mobile-first responsive design.

## Requirements

- Ruby 3.4.x, Rails 8.1
- Node 20+ (for the Tailwind toolchain)
- PostgreSQL 15+

## Getting started (development)

```bash
# 1. Point Bundler at the user gem dir (Arch --user-install quirk), if needed:
export GEM_HOME="$HOME/.local/share/gem/ruby/3.4.0"
export PATH="$GEM_HOME/bin:$PATH"

# 2. Install dependencies
bundle install

# 3. Database (dev/test use PostgreSQL on 127.0.0.1:5432; see config/database.yml).
#    Override host/user/password with DATABASE_HOST / DATABASE_USER / DATABASE_PASSWORD.
bin/rails db:prepare
bin/rails db:seed        # admin user + sample content

# 4. Run (Rails + Tailwind watcher)
bin/dev
```

Visit http://localhost:3000. Admin sign-in is at `/session/new`.
Default seeded admin: `admin@aktivesolutions.com` / `password`
(override with `ADMIN_EMAIL` / `ADMIN_PASSWORD` before `db:seed`).

In development, outgoing email opens in your browser via `letter_opener`.

## Configuration

Company details, NAP (name/address/phone), service areas, social links, GA4 id and
the Google Search Console token live in **`config/initializers/site.rb`**. Update the
`TODO` placeholders with real business details before launch.

## Tests

```bash
bin/rails test
```

## Deployment (westeros + Cloudflare Tunnel)

The app runs in production on the local **westeros** server and is exposed via
`cloudflared`. Cloudflare terminates TLS; Puma binds to localhost.

Required environment variables in production:

- `RAILS_MASTER_KEY` — from `config/master.key`
- `SECRET_KEY_BASE` — or rely on the master key
- `AKTIVE_SOLUTIONS_DATABASE_PASSWORD` — Postgres password
- `APP_HOST` — defaults to `aktivesolutions.com`
- `ADMIN_EMAIL` / `ADMIN_PASSWORD` — for the seeded admin

```bash
RAILS_ENV=production bin/rails db:prepare db:seed
RAILS_ENV=production bin/rails assets:precompile
RAILS_ENV=production bin/rails server        # bind to 127.0.0.1, front with cloudflared
```

`config/environments/production.rb` already trusts the Cloudflare proxy
(`assume_ssl`), forces SSL, sets the mailer/URL host, and restricts `config.hosts`
to the app domain. Configure SMTP credentials for outgoing lead emails.

Post-launch: verify the site in Google Search Console, submit
`https://aktivesolutions.com/sitemap.xml`, and set up a Google Business Profile
for local SEO.
