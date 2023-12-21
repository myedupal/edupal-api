class CreateSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects, id: :uuid do |t|
      t.string :name
      t.references :curriculum, null: false, foreign_key: true, type: :uuid
      t.string :code

      t.timestamps
    end
  end
end
