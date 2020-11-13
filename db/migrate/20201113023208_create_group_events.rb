class CreateGroupEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :group_events do |t|
      t.datetime :start
      t.datetime :end
      t.integer :duration
      t.string :name
      t.text :description
      t.string :location
      t.boolean :is_draft
      t.string :is_publish_boolean
      t.boolean :is_deleted

      t.timestamps
    end
  end
end
