Rails.application.routes.draw do
  # Admin authentication (Rails 8 generated)
  resource :session
  resources :passwords, param: :token

  # Health check for load balancers / uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # Marketing pages
  get "about",     to: "pages#about"
  get "services",  to: "pages#services"
  get "services/web-development",        to: "pages#web_development",    as: :web_development
  get "services/mobile-app-development", to: "pages#mobile_development", as: :mobile_development
  get "privacy",   to: "pages#privacy"
  get "terms",     to: "pages#terms"
  get "thank-you", to: "pages#thank_you", as: :thank_you

  # Portfolio (case studies)
  get "portfolio",       to: "case_studies#index"
  get "portfolio/:slug", to: "case_studies#show", as: :portfolio_item

  # Blog
  get "blog",       to: "posts#index"
  get "blog/:slug", to: "posts#show", as: :blog_post

  # Contact + lead capture (same URL handles the form and its submission)
  get  "contact", to: "leads#new",    as: :contact
  post "contact", to: "leads#create"

  # Admin dashboard
  namespace :admin do
    root "dashboard#index"
    resources :leads, only: %i[index show update destroy]
    resources :posts
    resources :case_studies
    resources :testimonials
  end

  # SEO machine-readable files
  get "sitemap.xml", to: "sitemaps#index", as: :sitemap, defaults: { format: "xml" }
  get "robots.txt",  to: "robots#index",   as: :robots,  defaults: { format: "text" }
end
