# frozen_string_literal: true

module Admin
  class LeadsController < BaseController
    before_action :set_lead, only: %i[show update destroy]

    def index
      @statuses = Lead.statuses.keys
      @status = params[:status].presence_in(@statuses)
      @leads = Lead.recent
      @leads = @leads.where(status: @status) if @status
    end

    def show; end

    def update
      if @lead.update(lead_params)
        redirect_to admin_lead_path(@lead), notice: "Lead updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      @lead.destroy
      redirect_to admin_leads_path, notice: "Lead deleted.", status: :see_other
    end

    private

    def set_lead
      @lead = Lead.find(params[:id])
    end

    def lead_params
      params.require(:lead).permit(:status, :admin_notes)
    end
  end
end
