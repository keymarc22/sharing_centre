class CreateGoogleCalendars < ActiveRecord::Migration[8.0]
  def change
    create_table :google_calendars do |t|
      t.references :user, null: false, foreign_key: true
      t.string :calendar_id, null: false
      t.string :summary
      t.string :time_zone
      t.string :sync_token
      t.string :watch_channel_id
      t.datetime :watch_expires_at
      t.datetime :last_synced_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    
    add_index :google_calendars, [:user_id, :calendar_id], unique: true
    add_index :google_calendars, :watch_channel_id
  end
end
