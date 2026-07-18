class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :company
      t.string :project_type
      t.string :budget_range
      t.string :timeline
      t.text :message
      t.string :source_page
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.integer :status, null: false, default: 0
      t.text :admin_notes

      t.timestamps
    end
    add_index :leads, :status
    add_index :leads, :created_at
  end
end
