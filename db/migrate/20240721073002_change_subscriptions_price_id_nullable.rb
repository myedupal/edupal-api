class ChangeSubscriptionsPriceIdNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :subscriptions, :price_id, true
  end
end
