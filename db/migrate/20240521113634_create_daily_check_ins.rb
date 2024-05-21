class CreateDailyCheckIns < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_check_ins, id: :uuid do |t|
      t.date :date, null: false
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid

      t.timestamps
    end

    add_index :daily_check_ins, [:date, :user_id], unique: true
  end
end
