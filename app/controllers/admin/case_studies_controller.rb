# frozen_string_literal: true

module Admin
  class CaseStudiesController < BaseController
    before_action :set_case_study, only: %i[edit update destroy]

    def index
      @case_studies = CaseStudy.ordered
    end

    def new
      @case_study = CaseStudy.new
    end

    def create
      @case_study = CaseStudy.new(case_study_params)
      if @case_study.save
        redirect_to admin_case_studies_path, notice: "Case study created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @case_study.update(case_study_params)
        redirect_to admin_case_studies_path, notice: "Case study updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @case_study.destroy
      redirect_to admin_case_studies_path, notice: "Case study deleted.", status: :see_other
    end

    private

    def set_case_study
      @case_study = CaseStudy.find(params[:id])
    end

    def case_study_params
      params.require(:case_study).permit(:title, :slug, :summary, :body, :client,
        :industry, :tech_stack, :results, :url, :featured, :published, :position,
        :meta_description, :cover_image)
    end
  end
end
