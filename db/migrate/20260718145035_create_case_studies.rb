class CreateCaseStudies < ActiveRecord::Migration[8.1]
  def change
    create_table :case_studies do |t|
      t.string :title
      t.string :slug
      t.text :summary
      t.string :client
      t.string :industry
      t.string :tech_stack
      t.string :results
      t.string :url
      t.boolean :featured, null: false, default: false
      t.boolean :published, null: false, default: false
      t.integer :position, null: false, default: 0
      t.string :meta_description

      t.timestamps
    end
    add_index :case_studies, :slug, unique: true
    add_index :case_studies, [:published, :position]
  end
end
