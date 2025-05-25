class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.string :name, null: false
      t.string :language_level # referencial
      t.string :language, null: false
      t.timestamps
    end

    create_table :lesson_topics do |t|
      t.references :lesson
      t.string :name, null: false
      t.string :category, null: false # writing, listening, etc
      # t.text :files

      t.timestamps
    end

    create_table :personalized_program_topics do |t|
      t.references :lesson_topic
      t.references :personalized_program
      # t.text :files

      t.timestamps
    end

    create_table :personalized_programs do |t|
      t.references :student

      t.timestamps
    end

    add_index :lessons, :name, unique: true
    add_index :lessons, :language
    add_index :lessons, :language_level
    add_index :lesson_topics, :name
    add_index :lesson_topics, :category
  end
end
