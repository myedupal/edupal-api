class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions, id: :uuid do |t|
      t.references :exam, null: false, foreign_key: true, type: :uuid
      t.string :number
      t.string :question_type
      t.text :text
      t.jsonb :metadata

      t.timestamps
    end
  end
end
