# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_25_014018) do
  create_table "lesson_topics", force: :cascade do |t|
    t.integer "lesson_id"
    t.string "name", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_lesson_topics_on_category"
    t.index ["lesson_id"], name: "index_lesson_topics_on_lesson_id"
    t.index ["name"], name: "index_lesson_topics_on_name"
  end

  create_table "lessons", force: :cascade do |t|
    t.string "name", null: false
    t.string "language_level"
    t.string "language", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language"], name: "index_lessons_on_language"
    t.index ["language_level"], name: "index_lessons_on_language_level"
    t.index ["name"], name: "index_lessons_on_name", unique: true
  end

  create_table "personalized_program_topics", force: :cascade do |t|
    t.integer "lesson_topic_id"
    t.integer "personalized_program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_topic_id"], name: "index_personalized_program_topics_on_lesson_topic_id"
    t.index ["personalized_program_id"], name: "index_personalized_program_topics_on_personalized_program_id"
  end

  create_table "personalized_programs", force: :cascade do |t|
    t.integer "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_personalized_programs_on_student_id"
  end

  create_table "program_intervals", force: :cascade do |t|
    t.integer "study_interval_id"
    t.integer "program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_program_intervals_on_program_id"
    t.index ["study_interval_id", "program_id"], name: "index_program_intervals_on_study_interval_id_and_program_id", unique: true
    t.index ["study_interval_id"], name: "index_program_intervals_on_study_interval_id"
  end

  create_table "programs", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "MXN", null: false
    t.integer "status", default: 0, null: false
    t.string "language", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language"], name: "index_programs_on_language"
    t.index ["name"], name: "index_programs_on_name", unique: true
  end

  create_table "student_programs", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "program_id"
    t.integer "study_interval_id"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "MXN", null: false
    t.integer "study_sessions", null: false
    t.string "study_frequency", null: false
    t.integer "status", default: 0, null: false
    t.string "language", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_student_programs_on_program_id"
    t.index ["student_id", "status"], name: "idx_student_active_program", unique: true, where: "status = 0"
    t.index ["student_id"], name: "index_student_programs_on_student_id"
    t.index ["study_interval_id"], name: "index_student_programs_on_study_interval_id"
  end

  create_table "study_intervals", force: :cascade do |t|
    t.string "name", null: false
    t.integer "study_sessions", null: false
    t.integer "study_frequency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "country_code", null: false
    t.string "phone"
    t.json "custom_data"
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", default: "User", null: false
    t.integer "active_program_id"
    t.index ["active_program_id"], name: "index_users_on_active_program_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "users", "student_programs", column: "active_program_id"
end
