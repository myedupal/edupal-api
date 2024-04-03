class CreateUserExamQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_exam_questions, id: :uuid do |t|
      t.references :user_exam, null: false, foreign_key: true, type: :uuid
      t.references :question, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :user_exam_questions, %i[user_exam_id question_id], unique: true
  end
end
