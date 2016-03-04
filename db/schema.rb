# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160304162802) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "youtube_id", limit: 255
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
    t.boolean  "music"
  end

  create_table "series", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title",      limit: 255
    t.string   "regex",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
  end

  create_table "series_channels", force: :cascade do |t|
    t.integer "series_id"
    t.integer "channel_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",         limit: 255
    t.string   "uid",           limit: 255
    t.string   "name",          limit: 255
    t.string   "image",         limit: 255
    t.string   "refresh_token", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "youtube_id",   limit: 255
    t.boolean  "watched",                  default: false, null: false
    t.string   "title",        limit: 255
    t.string   "thumbnail",    limit: 255
    t.integer  "series_id"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "love",                     default: false, null: false
    t.integer  "plays",                    default: 0,     null: false
    t.datetime "published_at"
  end

end
