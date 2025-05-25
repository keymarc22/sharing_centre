class CreatePrograms < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :type, :string, null: false, default: 'User'

    create_table :programs do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.monetize :price, null: false
      t.integer :status, null: false, default: 0
      t.string :language, null: false
      t.timestamps null: false
    end

    create_table :student_programs do |t|
      t.references :student, null: false
      t.references :program
      t.references :study_interval

      t.monetize :price, null: false

      t.integer :study_sessions, null: false # 4 classes
      t.string :study_frequency, null: false # 2_per_week
      t.integer :status, null: false, default: 0

      t.string :language, null: false

      t.date :start_date, null: false
      t.date :end_date

      t.timestamps
    end


    create_table :program_intervals do |t|
      t.references :study_interval
      t.references :program

      t.timestamps
    end

    add_index :program_intervals, [:study_interval_id, :program_id], unique: true

    create_table :study_intervals do |t|
      t.string :name, null: false
      t.integer :study_sessions, null: false # 4 classes
      t.integer :study_frequency, null: false  # 2_per_week/1_per_month

      t.timestamps
    end

    add_reference :users, :active_program, foreign_key: { to_table: :student_programs }

    add_index :programs, :name, unique: true
    add_index :programs, :language
    add_index :student_programs, [:student_id, :status], unique: true, where: "status = 0", name: 'idx_student_active_program'
  end
end
