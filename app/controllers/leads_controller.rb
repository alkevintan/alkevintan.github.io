# frozen_string_literal: true

class LeadsController < PublicController
  def new
    @lead = Lead.new(
      utm_source: params[:utm_source],
      utm_medium: params[:utm_medium],
      utm_campaign: params[:utm_campaign]
    )
  end

  def create
    @lead = Lead.new(lead_params)
    @lead.source_page = params[:source_page].presence || request.referer

    if spam?
      # Silently accept bots so they don't retry, but don't store or notify.
      redirect_to thank_you_path
    elsif @lead.save
      LeadMailer.new_lead(@lead).deliver_later
      redirect_to thank_you_path
    else
      flash.now[:alert] = "Please fix the highlighted fields and try again."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def lead_params
    params.require(:lead).permit(
      :name, :email, :phone, :company, :project_type, :budget_range,
      :timeline, :message, :utm_source, :utm_medium, :utm_campaign
    )
  end

  # Honeypot ("website" is hidden from humans) + a submit-too-fast time trap.
  def spam?
    return true if params[:website].present?

    loaded = params[:form_loaded_at].to_i
    loaded.positive? && (Time.current.to_i - loaded) < 3
  end
end
