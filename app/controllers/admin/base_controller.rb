# frozen_string_literal: true

module Admin
  # All admin controllers require authentication (the default from the
  # Authentication concern) and use the admin layout.
  class BaseController < ApplicationController
    layout "admin"

    helper_method :current_user

    private

    def current_user
      Current.user
    end
  end
end
