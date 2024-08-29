class CreateStudyGoals < ActiveRecord::Migration[7.0]
  def change
    create_table :study_goals, id: :uuid do |t|
      t.references :user, foreign_key: { to_table: :accounts }, type: :uuid, null: false
      t.references :curriculum,  null: false, foreign_key: true, type: :uuid
      t.integer :a_grade_count

      t.timestamps
    end

    create_table :study_goal_subjects, id: :uuid do |t|
      t.references :study_goal,  null: false, foreign_key: true, type: :uuid
      t.references :subject,  null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
