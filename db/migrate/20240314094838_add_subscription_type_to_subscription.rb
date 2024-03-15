class AddSubscriptionTypeToSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :razorpay_subscription_id, :string
    add_column :subscriptions, :razorpay_short_url, :string
  end
end
