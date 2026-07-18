# frozen_string_literal: true

class CaseStudiesController < PublicController
  def index
    @case_studies = CaseStudy.live.ordered
  end

  def show
    @case_study = CaseStudy.live.find_by!(slug: params[:slug])
  end
end
