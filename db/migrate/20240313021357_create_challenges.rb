class CreateChallenges < ActiveRecord::Migration[7.0]
  def change
    create_table :challenges, id: :uuid do |t|
      t.string :title
      t.string :challenge_type
      t.datetime :start_at
      t.datetime :end_at
      t.integer :reward_points, null: false, default: 0
      t.string :reward_type
      t.integer :penalty_seconds, null: false, default: 0
      t.references :subject, null: true, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
