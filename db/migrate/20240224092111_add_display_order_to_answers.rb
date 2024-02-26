class AddDisplayOrderToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :answers, :display_order, :integer
  end
end
