class CreateActivityQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_questions, id: :uuid do |t|
      t.references :activity, null: false, foreign_key: true, type: :uuid
      t.references :question, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :activity_questions, %i[activity_id question_id], unique: true
  end
end
