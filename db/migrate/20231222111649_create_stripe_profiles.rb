class CreateStripeProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :stripe_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.string :customer_id
      t.string :payment_method_id
      t.string :current_setup_intent_id

      t.timestamps
    end
  end
end
