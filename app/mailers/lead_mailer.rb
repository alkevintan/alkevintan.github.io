# frozen_string_literal: true

class LeadMailer < ApplicationMailer
  # Notifies the studio owner when a new lead comes in.
  def new_lead(lead)
    @lead = lead
    mail(
      # Where new-lead alerts land. Defaults to the site inbox; set LEAD_NOTIFICATION_TO
      # to route them to any monitored mailbox (Resend can deliver anywhere).
      to: ENV.fetch("LEAD_NOTIFICATION_TO") { SITE[:email] },
      reply_to: lead.email,
      subject: "New lead: #{lead.display_name}#{" (#{lead.project_type})" if lead.project_type.present?}"
    )
  end
end
