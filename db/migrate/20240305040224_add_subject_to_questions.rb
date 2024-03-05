class AddSubjectToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_reference :questions, :subject, null: true, foreign_key: true, type: :uuid

    reversible do |dir|
      dir.up do
        Exam.find_each do |exam|
          exam.questions.update_all(subject_id: exam.paper.subject_id)
        end
      end
    end

    change_column_null :questions, :subject_id, false
  end
end
