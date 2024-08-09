class AddIssToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :oauth2_iss, :string
    add_column :accounts, :oauth2_aud, :string
  end
end
