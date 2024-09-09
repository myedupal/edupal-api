class CreateGuessWordPools < ActiveRecord::Migration[7.0]
  def change
    create_table :guess_word_pools, id: :uuid do |t|
      t.boolean :default_pool, default: false
      t.references :subject, null: true, foreign_key: true, type: :uuid
      t.references :user, null: true, foreign_key: { to_table: :accounts }, type: :uuid

      t.string :title
      t.string :description
      t.boolean :published, null: false, default: false
      t.integer :guess_word_questions_count, null: false, default: 0

      t.index [:user_id, :subject_id]
      t.index [:default_pool, :subject_id]
      t.index [:default_pool, :subject_id], unique: true, where: '(default_pool IS TRUE)', name: 'index_guess_word_pools_on_default_pool_true_and_subject_id'

      t.timestamps
    end

    create_table :guess_word_questions, id: :uuid do |t|
      t.references :guess_word_pool, null: false, foreign_key: true, type: :uuid
      t.string :word
      t.string :description

      t.index [:guess_word_pool_id, :word], unique: true

      t.timestamps
    end

    change_table :guess_words do |t|
      t.references :guess_word_pool, null: true, foreign_key: true, type: :uuid
    end
  end
end
