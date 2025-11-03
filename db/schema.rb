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

ActiveRecord::Schema[7.1].define(version: 2025_11_03_143353) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "player_id", null: false
    t.bigint "question_id", null: false
    t.string "answer"
    t.float "time_taken"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_answers_on_player_id"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["room_id"], name: "index_answers_on_room_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.string "username"
    t.string "avatar"
    t.integer "score"
    t.integer "position"
    t.string "uuid"
    t.string "player_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_players_on_room_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.text "sentence"
    t.integer "question_type"
    t.integer "time_limit"
    t.integer "points"
    t.integer "question_number"
    t.string "correct_answer"
    t.json "possible_answers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "name"
    t.integer "questions_count"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "room_code"
    t.bigint "quiz_id", null: false
    t.integer "host_user_id"
    t.integer "status"
    t.integer "current_question_index"
    t.datetime "started_at"
    t.integer "max_players"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_rooms_on_quiz_id"
  end

  add_foreign_key "answers", "players"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "rooms"
  add_foreign_key "players", "rooms"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "rooms", "quizzes"
end
