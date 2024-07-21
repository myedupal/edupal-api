class AddRedeemCodeToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :redeem_code, :string
  end
end
