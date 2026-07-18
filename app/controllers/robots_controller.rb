# frozen_string_literal: true

# Dynamic robots.txt — allows crawling + points to the sitemap in production,
# and blocks everything in non-production environments.
class RobotsController < PublicController
  def index
    respond_to do |format|
      format.text { render layout: false }
    end
  end
end
