class CreateGuessWords < ActiveRecord::Migration[7.0]
  def change
    create_table :guess_words, id: :uuid do |t|
      t.references :subject, null: false, foreign_key: true, type: :uuid
      t.integer :guess_word_submissions_count, default: 0
      t.string :answer, null: false
      t.string :description
      t.integer :attempts, default: 6, null: false
      t.integer :reward_points, default: 0, null: false

      t.datetime :start_at
      t.datetime :end_at
      t.timestamps
    end

    create_table :guess_word_submissions, id: :uuid do |t|
      t.references :guess_word, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.integer :guesses_count, default: 0
      t.index [:guess_word_id, :user_id], unique: true
      t.string :status
      t.datetime :completed_at

      t.timestamps
    end

    create_table :guess_word_submission_guesses, id: :uuid do |t|
      t.references :guess_word_submission, null: false, foreign_key: true, type: :uuid
      t.string :guess
      t.text :result, array: true, default: []

      t.timestamps
    end

    create_table :guess_word_dictionaries, id: :uuid do |t|
      t.string :word, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
