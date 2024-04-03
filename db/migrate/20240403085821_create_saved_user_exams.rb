class CreateSavedUserExams < ActiveRecord::Migration[7.0]
  def change
    create_table :saved_user_exams, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :user_exam, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :saved_user_exams, %i[user_id user_exam_id], unique: true
  end
end
