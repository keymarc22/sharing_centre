class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :name, null: false
      t.string :language_level
      t.string :language, null: false
      t.string :keywords
      t.references :lesson
      t.references :lesson_topic

      t.timestamps
    end

    create_table :student_book_lists, id: false do |t|
      t.references :book, null: false
      t.references :book_list, null: false
    end

    create_table :book_lists do |t|
      t.string :name, null: false
      t.references :student, null: false

      t.timestamps
    end

    add_index :student_book_lists, [:book_id, :book_list_id], unique: true
    add_index :books, :name
    add_index :books, :language_level
    add_index :books, :language
    add_index :book_lists, [:name, :student_id], unique: true
  end
end
