class CreateUserCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :user_collections, id: :uuid do |t|
      t.references :user, foreign_key: { to_table: :accounts }, type: :uuid, null: false
      t.references :curriculum, null: false, foreign_key: true, type: :uuid
      t.string :collection_type, null: false

      t.string :title
      t.string :description
      t.integer :questions_count, default: 0

      t.timestamps
    end

    create_table :user_collection_questions, id: :uuid do |t|
      t.references :user_collection, null: false, foreign_key: true, type: :uuid
      t.references :question, null: false, foreign_key: true, type: :uuid

      t.timestamps

      t.index %i[question_id user_collection_id], unique: true, name: 'index_user_collection_questions_on_question_and_collection'
    end
  end
end
