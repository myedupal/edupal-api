class CreateAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers, id: :uuid do |t|
      t.references :question, null: false, foreign_key: true, type: :uuid
      t.text :text
      t.string :image

      t.timestamps
    end
  end
end
