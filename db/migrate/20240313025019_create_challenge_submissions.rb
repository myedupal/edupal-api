class CreateChallengeSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :challenge_submissions, id: :uuid do |t|
      t.references :challenge, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.string :status
      t.integer :score
      t.integer :total_score
      t.integer :completion_seconds
      t.integer :penalty_seconds
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
