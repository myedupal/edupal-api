class CreateQuestionTopics < ActiveRecord::Migration[7.0]
  def change
    create_table :question_topics, id: :uuid do |t|
      t.references :question, null: false, foreign_key: true, type: :uuid
      t.references :topic, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
