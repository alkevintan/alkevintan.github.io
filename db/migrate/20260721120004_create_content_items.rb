# frozen_string_literal: true

class CreateContentItems < ActiveRecord::Migration[8.1]
  def change
    create_table :content_items do |t|
      t.string  :page,      null: false
      t.string  :section,   null: false
      t.integer :position,  null: false, default: 0
      t.boolean :published, null: false, default: true
      t.string  :title
      t.text    :body
      t.jsonb   :meta,      null: false, default: {}

      t.timestamps
    end
    add_index :content_items, %i[page section position]
  end
end
