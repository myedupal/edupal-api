class AddIsPublishedToChallenges < ActiveRecord::Migration[7.0]
  def change
    add_column :challenges, :is_published, :boolean, default: false, null: false
  end
end
