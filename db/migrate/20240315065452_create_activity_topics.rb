class CreateActivityTopics < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_topics, id: :uuid do |t|
      t.references :activity, null: false, foreign_key: true, type: :uuid
      t.references :topic, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :activity_topics, [:activity_id, :topic_id], unique: true
  end
end
