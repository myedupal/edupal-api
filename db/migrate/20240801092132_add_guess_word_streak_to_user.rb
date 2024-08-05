class AddGuessWordStreakToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :guess_word_daily_streak, :integer, default: 0, null: false
  end
end
