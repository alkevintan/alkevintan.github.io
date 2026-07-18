class CreateTestimonials < ActiveRecord::Migration[8.1]
  def change
    create_table :testimonials do |t|
      t.string :author_name
      t.string :role
      t.string :company
      t.text :quote
      t.integer :rating, default: 5
      t.boolean :featured, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :testimonials, [:featured, :position]
  end
end
