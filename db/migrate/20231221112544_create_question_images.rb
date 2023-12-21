class CreateQuestionImages < ActiveRecord::Migration[7.0]
  def change
    create_table :question_images, id: :uuid do |t|
      t.references :question, null: false, foreign_key: true, type: :uuid
      t.string :image
      t.integer :display_order

      t.timestamps
    end
  end
end
