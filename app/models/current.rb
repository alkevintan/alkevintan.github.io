class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :site_setting
  delegate :user, to: :session, allow_nil: true
end
