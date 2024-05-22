class RenameChallengeSubmissionsTableToSubmissions < ActiveRecord::Migration[7.0]
  def change
    rename_table :challenge_submissions, :submissions
    change_column_null :submissions, :challenge_id, true
    rename_column :submission_answers, :challenge_submission_id, :submission_id
    change_column_null :submission_answers, :submission_id, false
  end
end
