class CreateQuotes < ActiveRecord::Migration[7.0]
  def change
    create_table :quotes, id: :uuid do |t|
      t.references :user, foreign_key: { to_table: :accounts }, type: :uuid, null: false
      t.references :created_by, foreign_key: { to_table: :accounts }, type: :uuid, null: false
      t.string :stripe_quote_id
      t.string :status
      t.datetime :quote_expire_at

      t.timestamps
    end

    add_reference :subscriptions,:quote, foreign_key: { to_table: :quotes }, type: :uuid, null: true
  end
end
