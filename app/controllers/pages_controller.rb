# frozen_string_literal: true

# Static marketing pages. Page-level SEO metadata is set inside each view
# via `set_meta`. Content is expanded in the Marketing Pages task.
class PagesController < ApplicationController
  def home; end
  def about; end
  def services; end
  def web_development; end
  def mobile_development; end
  def portfolio; end
  def contact; end
  def blog; end
  def privacy; end
  def terms; end
  def thank_you; end
end
