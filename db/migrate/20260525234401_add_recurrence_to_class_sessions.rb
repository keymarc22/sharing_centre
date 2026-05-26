class AddRecurrenceToClassSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :class_sessions, :recurrence_rule, :string
    add_column :class_sessions, :recurrence_ends_at, :date
  end
end
