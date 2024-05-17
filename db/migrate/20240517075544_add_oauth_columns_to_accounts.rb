class AddOauthColumnsToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :oauth2_provider, :string
    add_column :accounts, :oauth2_sub, :string
    add_column :accounts, :oauth2_profile_picture_url, :string
  end
end
