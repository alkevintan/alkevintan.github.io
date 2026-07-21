# frozen_string_literal: true

# A single editable copy field on a marketing page, addressed by (page, key).
# Falls back to the PageContent registry default when absent or blank.
class ContentBlock < ApplicationRecord
  validates :page, presence: true
  validates :key,  presence: true, uniqueness: { scope: :page }

  def self.value_for(page, key)
    where(page: page, key: key).pick(:content)
  end
end
