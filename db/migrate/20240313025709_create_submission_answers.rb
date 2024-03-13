class CreateSubmissionAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_answers, id: :uuid do |t|
      t.references :challenge_submission, null: true, foreign_key: true, type: :uuid
      t.references :question, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.string :answer, null: false
      t.boolean :is_correct, default: false, null: false
      t.integer :score, default: 0, null: false

      t.timestamps
    end
  end
end
