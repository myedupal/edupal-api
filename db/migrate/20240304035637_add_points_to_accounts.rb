class AddPointsToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :points, :integer, default: 0, null: false
  end
end
