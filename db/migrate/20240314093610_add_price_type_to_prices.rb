class AddPriceTypeToPrices < ActiveRecord::Migration[7.0]
  def change
    add_column :prices, :razorpay_plan_id, :string
  end
end
