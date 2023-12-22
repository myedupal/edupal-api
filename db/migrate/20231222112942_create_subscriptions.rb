class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :plan, null: false, foreign_key: true, type: :uuid
      t.references :price, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :created_by, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :auto_renew, default: true, null: false
      t.string :stripe_subscription_id
      t.string :status
      t.boolean :cancel_at_period_end, default: false, null: false
      t.datetime :canceled_at
      t.string :cancel_reason
      t.datetime :current_period_start
      t.datetime :current_period_end

      t.timestamps
    end
  end
end
