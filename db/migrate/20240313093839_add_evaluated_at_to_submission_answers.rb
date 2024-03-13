class AddEvaluatedAtToSubmissionAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_answers, :evaluated_at, :datetime
  end
end
