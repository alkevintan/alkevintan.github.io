# frozen_string_literal: true

module Admin
  class LeadOptionsController < BaseController
    before_action :set_lead_option, only: %i[edit update destroy]

    def index
      @lead_options = LeadOption.order(:field, :position, :id)
    end

    def new
      @lead_option = LeadOption.new(field: params[:field].presence_in(LeadOption::FIELD_LABELS.keys) || "project_type")
    end

    def create
      @lead_option = LeadOption.new(lead_option_params)
      if @lead_option.save
        redirect_to admin_lead_options_path, notice: "Option created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @lead_option.update(lead_option_params)
        redirect_to admin_lead_options_path, notice: "Option updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @lead_option.destroy
      redirect_to admin_lead_options_path, notice: "Option deleted.", status: :see_other
    end

    private

    def set_lead_option
      @lead_option = LeadOption.find(params[:id])
    end

    def lead_option_params
      params.require(:lead_option).permit(:field, :label, :position, :published)
    end
  end
end
