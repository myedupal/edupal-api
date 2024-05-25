class AddSubmissionAnswersCountToSubmissions < ActiveRecord::Migration[7.0]
  def up
    add_column :submissions, :total_submitted_answers, :integer, default: 0
    add_column :submissions, :total_correct_answers, :integer, default: 0

    Submission.submitted.includes(:submission_answers).find_each do |submission|
      submission.update_columns(
        total_submitted_answers: submission.submission_answers.size,
        total_correct_answers: submission.submission_answers.select(&:is_correct?).size
      )
    end
  end

  def down
    remove_column :submissions, :total_submitted_answers
    remove_column :submissions, :total_correct_answers
  end
end
