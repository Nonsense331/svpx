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

ActiveRecord::Schema[7.0].define(version: 2025_07_10_200748) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "youtube_id"
    t.string "title"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "order"
    t.boolean "music"
  end

  create_table "series", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.string "regex"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "order"
  end

  create_table "series_channels", id: :serial, force: :cascade do |t|
    t.integer "series_id"
    t.integer "channel_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "uid"
    t.string "name"
    t.string "image"
    t.string "refresh_token"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "videos", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "youtube_id"
    t.boolean "watched", default: false, null: false
    t.string "title"
    t.string "thumbnail"
    t.integer "series_id"
    t.integer "channel_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "love", default: false, null: false
    t.integer "plays", default: 0, null: false
    t.datetime "published_at", precision: nil
    t.integer "music_counter"
    t.boolean "hate", default: false, null: false
  end

end
