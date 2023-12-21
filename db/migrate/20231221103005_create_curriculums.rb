class CreateCurriculums < ActiveRecord::Migration[7.0]
  def change
    create_table :curriculums, id: :uuid do |t|
      t.string :name
      t.string :board
      t.integer :display_order

      t.timestamps
    end
  end
end
