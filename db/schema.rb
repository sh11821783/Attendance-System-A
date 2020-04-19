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

ActiveRecord::Schema.define(version: 20200329014145) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.time "scheduled_end_time" # 予定終了時間
    t.string "business_processing_content" # 業務処理内容
    t.string "instructor_confirmation" # 指示者確認
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "affiliation" # 所属
    t.integer "employee_number" # ユーザーの社員番号
    t.string "uid" # ユーザーのカードID
    t.time "basic_work_time"
    t.datetime "designated_work_start_time", default: "2020-04-19 00:00:00" # ユーザーの指定業務開始時間
    t.datetime "designated_work_end_time", default: "2020-04-19 09:00:00" # ユーザーの指定業務終了時間
    t.datetime "basic_time", default: "2020-04-18 23:00:00" # 基本時間
    t.boolean "superior" # 上長かどうかの真偽
    t.datetime "created_at", null: false # 作成日
    t.datetime "updated_at", null: false # 更新日
    t.string "password_digest" # password記入
    t.string "remember_digest"
    t.boolean "admin", default: false # 管理者かどうかの真偽
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
