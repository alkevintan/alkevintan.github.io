Rails.application.routes.draw do
  # Health check for load balancers / uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # Marketing pages
  get "about",     to: "pages#about"
  get "services",  to: "pages#services"
  get "services/web-development",        to: "pages#web_development",    as: :web_development
  get "services/mobile-app-development", to: "pages#mobile_development", as: :mobile_development
  get "portfolio", to: "pages#portfolio"
  get "privacy",   to: "pages#privacy"
  get "terms",     to: "pages#terms"
  get "thank-you", to: "pages#thank_you", as: :thank_you

  # Contact + lead capture (fleshed out in the Leads task; placeholder for now)
  get "contact", to: "pages#contact"

  # Blog (fleshed out in the Blog task; placeholder for now)
  get "blog", to: "pages#blog"

  # SEO machine-readable files
  get "sitemap.xml", to: "sitemaps#index", as: :sitemap, defaults: { format: "xml" }
  get "robots.txt",  to: "robots#index",   as: :robots,  defaults: { format: "text" }
end
