class CreateGoogleWatchChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :google_watch_channels do |t|
      t.string :channel_id, null: false
      t.string :resource_id, null: false
      t.string :resource_uri, null: false
      t.references :google_calendar, null: false, foreign_key: true
      t.datetime :expires_at, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    
    add_index :google_watch_channels, :channel_id, unique: true
    add_index :google_watch_channels, :resource_id
  end
end
