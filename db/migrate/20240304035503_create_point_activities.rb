class CreatePointActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :point_activities, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.bigint :points, default: 0, null: true
      t.string :action_type
      t.references :activity, polymorphic: true, null: true, type: :uuid

      t.timestamps
    end
  end
end
