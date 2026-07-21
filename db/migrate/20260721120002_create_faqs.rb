# frozen_string_literal: true

class CreateFaqs < ActiveRecord::Migration[8.1]
  def change
    create_table :faqs do |t|
      t.string  :page,      null: false
      t.string  :question,  null: false
      t.text    :answer,    null: false
      t.integer :position,  null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
    end
    add_index :faqs, %i[page position]
  end
end
