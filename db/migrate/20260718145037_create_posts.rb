class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.text :excerpt
      t.string :meta_title
      t.string :meta_description
      t.string :category
      t.string :tags
      t.string :author
      t.integer :status, null: false, default: 0
      t.datetime :published_at
      t.integer :reading_minutes

      t.timestamps
    end
    add_index :posts, :slug, unique: true
    add_index :posts, [:status, :published_at]
  end
end
