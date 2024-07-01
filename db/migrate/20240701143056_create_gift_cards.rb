class CreateGiftCards < ActiveRecord::Migration[7.0]
  def change
    create_table :gift_cards, id: :uuid do |t|
      t.string :name
      t.string :remark
      t.references :plan, null: false, foreign_key: true, type: :uuid
      t.references :created_by, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.integer :redemption_limit, null: false, default: 1
      t.integer :redemption_count, null: false, default: 0
      t.datetime :expires_at
      t.string :code, null: false

      t.timestamps
    end

    add_index :gift_cards, :code, unique: true
  end
end
