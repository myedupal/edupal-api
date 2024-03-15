class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.string :activity_type
      t.references :subject, null: false, foreign_key: true, type: :uuid
      t.references :exam, null: true, foreign_key: true, type: :uuid
      t.integer :activity_questions_count, default: 0
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end
  end
end
