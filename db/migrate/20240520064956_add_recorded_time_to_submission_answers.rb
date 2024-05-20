class AddRecordedTimeToSubmissionAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_answers, :recorded_time, :bigint, null: false, default: 0
  end
end
