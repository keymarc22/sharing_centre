class AddGoogleOauthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_oauth_token, :string
    add_column :users, :google_refresh_token, :string
    add_column :users, :google_token_expires_at, :datetime
    add_column :users, :time_zone, :string, default: 'UTC'
    
    add_index :users, :google_oauth_token
  end
end
