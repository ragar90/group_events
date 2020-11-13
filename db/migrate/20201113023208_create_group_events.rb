class CreateGroupEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :group_events do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.integer :duration
      t.string :name
      t.text :description
      t.string :location
      t.string :status, default: GroupEvent.statuses[:draft]
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
