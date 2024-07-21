class AddDurationToGiftCards < ActiveRecord::Migration[7.0]
  def change
    add_column :gift_cards, :duration, :integer
  end
end
