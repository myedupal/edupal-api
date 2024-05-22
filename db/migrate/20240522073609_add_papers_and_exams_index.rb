class AddPapersAndExamsIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :papers, %i[subject_id name], unique: true
    add_index :exams, %i[zone season year level], unique: true
  end
end
