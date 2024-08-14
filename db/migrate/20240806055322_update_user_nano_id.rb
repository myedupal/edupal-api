class UpdateUserNanoId < ActiveRecord::Migration[7.0]
  class Account < ApplicationRecord
    include NanoidGenerator
    # Disable inheritance since this migration updates every row
    self.inheritance_column = nil
  end

  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          Account.find_each do |account|
            account.set_nanoid
            account.save(touch: false, validate: false)
          end
        end
      end
    end

    add_index :accounts, :nanoid, unique: true
  end
end
