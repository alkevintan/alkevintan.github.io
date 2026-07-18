# frozen_string_literal: true

module AdminHelper
  # Shared styling for admin form inputs.
  def admin_input_class
    "mt-1.5 block w-full rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-900 focus:border-brand-500"
  end

  def admin_label_class
    "block text-sm font-medium text-slate-700"
  end
end
