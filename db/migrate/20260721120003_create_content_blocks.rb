# frozen_string_literal: true

class CreateContentBlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :content_blocks do |t|
      t.string :page, null: false
      t.string :key,  null: false
      t.text   :content

      t.timestamps
    end
    add_index :content_blocks, %i[page key], unique: true
  end
end
