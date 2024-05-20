class AddStreaksToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :daily_streak, :integer, default: 0, null: false
    add_column :accounts, :maximum_streak, :integer, default: 0, null: false
  end
end
