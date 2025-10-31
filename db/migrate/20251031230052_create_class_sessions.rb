class CreateClassSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :class_sessions do |t|
      # Basic session information
      t.references :teacher, foreign_key: { to_table: :users }, null: false
      t.references :student, foreign_key: { to_table: :users }, null: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.string :time_zone, default: 'UTC'
      t.string :location
      t.integer :status, default: 0, null: false
      
      # Google Calendar integration fields
      t.string :google_event_id
      t.string :google_calendar_owner # Legacy field for backward compatibility
      t.references :owner_user, foreign_key: { to_table: :users }
      t.references :owner_calendar, foreign_key: { to_table: :google_calendars }
      t.jsonb :google_event_raw
      t.string :google_event_etag
      t.datetime :google_event_updated_at
      t.string :google_calendar_timezone
      t.datetime :last_synced_at
      
      # Recurrence support
      t.string :recurrence_rule
      t.jsonb :recurrence_exceptions
      t.string :recurring_event_id
      t.datetime :original_start_time
      t.references :parent_session, foreign_key: { to_table: :class_sessions }

      t.timestamps
    end
    
    add_index :class_sessions, :google_event_id
    add_index :class_sessions, :recurring_event_id
    add_index :class_sessions, :start_at
    add_index :class_sessions, :status
    add_index :class_sessions, [:teacher_id, :start_at]
    add_index :class_sessions, [:student_id, :start_at]
  end
end
