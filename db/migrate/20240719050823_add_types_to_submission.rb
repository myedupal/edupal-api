class AddTypesToSubmission < ActiveRecord::Migration[7.0]
  def change
    add_reference :submissions, :user_exam, null: true, foreign_key: true, type: :uuid
    add_column :submissions, :mcq_type, :string
  end
end
