# frozen_string_literal: true

# Base controller for all publicly accessible pages. The Rails 8 auth system
# requires authentication by default, so public controllers opt out here.
class PublicController < ApplicationController
  allow_unauthenticated_access
end
