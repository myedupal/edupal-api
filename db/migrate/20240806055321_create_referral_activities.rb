class CreateReferralActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :referral_activities, id: :uuid do |t|
      t.references :user, foreign_key: { to_table: :accounts }, type: :uuid, null: true
      t.references :referral_source, polymorphic: true, null: true, type: :uuid

      t.string :referral_type
      t.boolean :voided, null: false, default: false
      t.monetize :credit

      t.timestamps
    end

    add_column :accounts, :nanoid, :string
    add_reference :accounts, :referred_by, foreign_key: { to_table: :accounts }, type: :uuid, null: true
    add_column :accounts, :referred_count, :integer, default: 0
    add_monetize :accounts, :referred_credit
  end
end
