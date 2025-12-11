class AddGoogleOauthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :avatar_url, :string
    add_column :users, :uid, :string
    add_column :users, :provider, :string
  end
end
