class UpdateExamsUniqueIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :exams, %i[zone season year level]
    add_index :exams, %i[paper_id zone season year level], unique: true, name: 'index_exams_unique'
  end
end
