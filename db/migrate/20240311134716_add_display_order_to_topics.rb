class AddDisplayOrderToTopics < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :display_order, :integer, default: 0
  end
end
