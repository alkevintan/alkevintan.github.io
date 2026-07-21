# frozen_string_literal: true

class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.string  :menu,      null: false
      t.string  :label,     null: false
      t.string  :url,       null: false
      t.integer :position,  null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
    end
    add_index :menu_items, %i[menu position]
  end
end
