class AddReferralFeePercentageToPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :plans, :referral_fee_percentage, :decimal, precision: 5, scale: 2, default: 0.0
  end
end
