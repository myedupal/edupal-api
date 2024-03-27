class AddColumnsToActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :title, :string
    add_column :activities, :recorded_time, :bigint, null: false, default: 0
  end
end
