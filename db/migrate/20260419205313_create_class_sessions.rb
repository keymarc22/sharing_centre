class CreateClassSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :class_sessions do |t|
      t.references :teacher, null: false, foreign_key: { to_table: :users }
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :lesson, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.string :time_zone, default: 'UTC'
      t.string :meet_link
      t.string :google_event_id
      t.integer :google_calendar_owner_id

      t.timestamps
    end

    add_index :class_sessions, :google_event_id, unique: true, where: 'google_event_id IS NOT NULL'
    add_index :class_sessions, [:teacher_id, :start_at]
    add_index :class_sessions, [:student_id, :start_at]
  end
end
