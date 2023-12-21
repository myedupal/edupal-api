class CreateExams < ActiveRecord::Migration[7.0]
  def change
    create_table :exams, id: :uuid do |t|
      t.references :paper, null: false, foreign_key: true, type: :uuid
      t.integer :year
      t.string :season
      t.string :zone
      t.string :level
      t.string :file
      t.string :marking_scheme

      t.timestamps
    end
  end
end
