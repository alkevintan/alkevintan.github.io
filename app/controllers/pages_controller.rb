# frozen_string_literal: true

# Static marketing pages. Page-level SEO metadata is set inside each view
# via `set_meta`.
class PagesController < PublicController
  def home
    @featured_case_studies = CaseStudy.live.featured.ordered.limit(3)
    @testimonials = Testimonial.featured.ordered.limit(3)
    @recent_posts = Post.live.recent.limit(3)
  end

  def about; end
  def services; end
  def web_development; end
  def mobile_development; end
  def privacy; end
  def terms; end
  def thank_you; end
end
