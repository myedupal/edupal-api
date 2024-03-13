class CreateChallengeQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :challenge_questions, id: :uuid do |t|
      t.references :challenge, null: false, foreign_key: true, type: :uuid
      t.references :question, null: false, foreign_key: true, type: :uuid
      t.integer :display_order, null: false
      t.integer :score, null: false, default: 1

      t.timestamps
    end

    add_index :challenge_questions, [:challenge_id, :question_id], unique: true
  end
end
