class ApplicationMailer < ActionMailer::Base
  default from: %("#{SITE[:name]}" <#{SITE[:email]}>)
  layout "mailer"
end
