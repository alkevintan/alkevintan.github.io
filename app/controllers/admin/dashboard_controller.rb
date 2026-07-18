# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @total_leads = Lead.count
      @new_leads = Lead.new_lead.count
      @leads_by_status = Lead.group(:status).count
      @recent_leads = Lead.recent.limit(8)
      @posts_count = Post.count
      @published_posts = Post.published.count
      @case_studies_count = CaseStudy.count
      @testimonials_count = Testimonial.count
    end
  end
end
