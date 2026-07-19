class ApplicationMailer < ActionMailer::Base
  # From must be an address on a domain verified with the SMTP provider (Resend).
  # Override with MAILER_FROM env (e.g. "AktiveSolutions <noreply@aktivesolutions.com>").
  default from: ENV.fetch("MAILER_FROM") { %("#{SITE[:name]}" <#{SITE[:email]}>) }
  layout "mailer"
end
