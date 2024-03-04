class ChangeQuestionsExamIdToNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :questions, :exam_id, true
  end
end
