class AddSubmissionAnswerUniqueIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :submission_answers, %i[question_id submission_id], unique: true
  end
end
