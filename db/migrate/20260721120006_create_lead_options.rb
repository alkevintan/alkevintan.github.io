# frozen_string_literal: true

class CreateLeadOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :lead_options do |t|
      t.string  :field,     null: false
      t.string  :label,     null: false
      t.integer :position,  null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
    end
    add_index :lead_options, %i[field position]
  end
end
