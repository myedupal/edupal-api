class CreateTopics < ActiveRecord::Migration[7.0]
  def change
    create_table :topics, id: :uuid do |t|
      t.string :name
      t.references :subject, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
