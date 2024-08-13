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

ActiveRecord::Schema[7.0].define(version: 2024_08_12_064215) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "type", null: false
    t.string "name"
    t.string "phone_number"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "points", default: 0, null: false
    t.string "oauth2_provider"
    t.string "oauth2_sub"
    t.string "oauth2_profile_picture_url"
    t.integer "daily_streak", default: 0, null: false
    t.integer "maximum_streak", default: 0, null: false
    t.uuid "selected_curriculum_id"
    t.integer "guess_word_daily_streak", default: 0, null: false
    t.string "nanoid"
    t.uuid "referred_by_id"
    t.integer "referred_count", default: 0
    t.bigint "referred_credit_cents", default: 0, null: false
    t.string "referred_credit_currency", default: "USD", null: false
    t.string "oauth2_iss"
    t.string "oauth2_aud"
    t.index ["email", "type"], name: "index_accounts_on_email_and_type", unique: true, where: "((email IS NOT NULL) AND ((email)::text <> ''::text))"
    t.index ["phone_number"], name: "index_accounts_on_phone_number"
    t.index ["referred_by_id"], name: "index_accounts_on_referred_by_id"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["selected_curriculum_id"], name: "index_accounts_on_selected_curriculum_id"
  end

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "activity_type"
    t.uuid "subject_id", null: false
    t.uuid "exam_id"
    t.integer "activity_questions_count", default: 0
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.bigint "recorded_time", default: 0, null: false
    t.index ["exam_id"], name: "index_activities_on_exam_id"
    t.index ["subject_id"], name: "index_activities_on_subject_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "activity_papers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "activity_id", null: false
    t.uuid "paper_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id", "paper_id"], name: "index_activity_papers_on_activity_id_and_paper_id", unique: true
    t.index ["activity_id"], name: "index_activity_papers_on_activity_id"
    t.index ["paper_id"], name: "index_activity_papers_on_paper_id"
  end

  create_table "activity_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "activity_id", null: false
    t.uuid "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id", "question_id"], name: "index_activity_questions_on_activity_id_and_question_id", unique: true
    t.index ["activity_id"], name: "index_activity_questions_on_activity_id"
    t.index ["question_id"], name: "index_activity_questions_on_question_id"
  end

  create_table "activity_topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "activity_id", null: false
    t.uuid "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id", "topic_id"], name: "index_activity_topics_on_activity_id_and_topic_id", unique: true
    t.index ["activity_id"], name: "index_activity_topics_on_activity_id"
    t.index ["topic_id"], name: "index_activity_topics_on_topic_id"
  end

  create_table "answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "question_id", null: false
    t.text "text"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_order"
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "callback_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "request_headers"
    t.text "request_body"
    t.string "callback_from"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "challenge_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "challenge_id", null: false
    t.uuid "question_id", null: false
    t.integer "display_order", null: false
    t.integer "score", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id", "question_id"], name: "index_challenge_questions_on_challenge_id_and_question_id", unique: true
    t.index ["challenge_id"], name: "index_challenge_questions_on_challenge_id"
    t.index ["question_id"], name: "index_challenge_questions_on_question_id"
  end

  create_table "challenges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "challenge_type"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "reward_points", default: 0, null: false
    t.string "reward_type"
    t.integer "penalty_seconds", default: 0, null: false
    t.uuid "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_published", default: false, null: false
    t.index ["subject_id"], name: "index_challenges_on_subject_id"
  end

  create_table "curriculums", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "board"
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_published", default: false
  end

  create_table "daily_check_ins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "user_id"], name: "index_daily_check_ins_on_date_and_user_id", unique: true
    t.index ["user_id"], name: "index_daily_check_ins_on_user_id"
  end

  create_table "exams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "paper_id", null: false
    t.integer "year"
    t.string "season"
    t.string "zone"
    t.string "level"
    t.string "file"
    t.string "marking_scheme"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paper_id", "zone", "season", "year", "level"], name: "index_exams_unique", unique: true
    t.index ["paper_id"], name: "index_exams_on_paper_id"
  end

  create_table "gift_cards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "remark"
    t.uuid "plan_id", null: false
    t.uuid "created_by_id", null: false
    t.integer "redemption_limit", default: 1, null: false
    t.integer "redemption_count", default: 0, null: false
    t.datetime "expires_at"
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration"
    t.index ["created_by_id"], name: "index_gift_cards_on_created_by_id"
    t.index ["plan_id"], name: "index_gift_cards_on_plan_id"
  end

  create_table "guess_word_dictionaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "word", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word"], name: "index_guess_word_dictionaries_on_word", unique: true
  end

  create_table "guess_word_submission_guesses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "guess_word_submission_id", null: false
    t.string "guess"
    t.text "result", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guess_word_submission_id"], name: "index_guess_word_submission_guesses_on_guess_word_submission_id"
  end

  create_table "guess_word_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "guess_word_id", null: false
    t.uuid "user_id", null: false
    t.integer "guesses_count", default: 0
    t.string "status"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guess_word_id", "user_id"], name: "index_guess_word_submissions_on_guess_word_id_and_user_id", unique: true
    t.index ["guess_word_id"], name: "index_guess_word_submissions_on_guess_word_id"
    t.index ["user_id"], name: "index_guess_word_submissions_on_user_id"
  end

  create_table "guess_words", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subject_id", null: false
    t.integer "guess_word_submissions_count", default: 0
    t.string "answer", null: false
    t.string "description"
    t.integer "attempts", default: 6, null: false
    t.integer "reward_points", default: 0, null: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_guess_words_on_subject_id"
  end

  create_table "papers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id", "name"], name: "index_papers_on_subject_id_and_name", unique: true
    t.index ["subject_id"], name: "index_papers_on_subject_id"
  end

  create_table "plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.jsonb "limits"
    t.boolean "is_published"
    t.string "stripe_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plan_type"
    t.decimal "referral_fee_percentage", precision: 5, scale: 2, default: "0.0"
  end

  create_table "point_activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.bigint "points", default: 0
    t.string "action_type"
    t.string "activity_type"
    t.uuid "activity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_point_activities_on_account_id"
    t.index ["activity_type", "activity_id"], name: "index_point_activities_on_activity"
  end

  create_table "prices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "plan_id", null: false
    t.bigint "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.string "billing_cycle"
    t.string "stripe_price_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "razorpay_plan_id"
    t.index ["plan_id"], name: "index_prices_on_plan_id"
  end

  create_table "question_images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "question_id", null: false
    t.string "image"
    t.integer "display_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_images_on_question_id"
  end

  create_table "question_topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "question_id", null: false
    t.uuid "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_topics_on_question_id"
    t.index ["topic_id"], name: "index_question_topics_on_topic_id"
  end

  create_table "questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "exam_id"
    t.integer "number"
    t.string "question_type"
    t.text "text"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "subject_id", null: false
    t.index ["exam_id"], name: "index_questions_on_exam_id"
    t.index ["subject_id"], name: "index_questions_on_subject_id"
  end

  create_table "referral_activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "referral_source_type"
    t.uuid "referral_source_id"
    t.string "referral_type"
    t.boolean "voided", default: false, null: false
    t.bigint "credit_cents", default: 0, null: false
    t.string "credit_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referral_source_type", "referral_source_id"], name: "index_referral_activities_on_referral_source"
    t.index ["user_id"], name: "index_referral_activities_on_user_id"
  end

  create_table "saved_user_exams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "user_exam_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_exam_id"], name: "index_saved_user_exams_on_user_exam_id"
    t.index ["user_id", "user_exam_id"], name: "index_saved_user_exams_on_user_id_and_user_exam_id", unique: true
    t.index ["user_id"], name: "index_saved_user_exams_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "scope"
    t.string "token"
    t.datetime "revoked_at"
    t.datetime "expired_at"
    t.string "user_agent"
    t.string "remote_ip"
    t.string "referer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sessions_on_account_id"
    t.index ["token"], name: "index_sessions_on_token", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "stripe_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "customer_id"
    t.string "payment_method_id"
    t.string "current_setup_intent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_stripe_profiles_on_user_id"
  end

  create_table "subjects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "curriculum_id", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_published", default: false
    t.index ["curriculum_id"], name: "index_subjects_on_curriculum_id"
  end

  create_table "submission_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.uuid "question_id", null: false
    t.uuid "user_id", null: false
    t.string "answer", null: false
    t.boolean "is_correct", default: false, null: false
    t.integer "score", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "evaluated_at"
    t.bigint "recorded_time", default: 0, null: false
    t.index ["question_id", "submission_id"], name: "index_submission_answers_on_question_id_and_submission_id", unique: true
    t.index ["question_id"], name: "index_submission_answers_on_question_id"
    t.index ["submission_id"], name: "index_submission_answers_on_submission_id"
    t.index ["user_id"], name: "index_submission_answers_on_user_id"
  end

  create_table "submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "challenge_id"
    t.uuid "user_id", null: false
    t.string "status"
    t.integer "score"
    t.integer "total_score"
    t.integer "completion_seconds"
    t.integer "penalty_seconds"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "total_submitted_answers", default: 0
    t.integer "total_correct_answers", default: 0
    t.uuid "user_exam_id"
    t.string "mcq_type"
    t.index ["challenge_id"], name: "index_submissions_on_challenge_id"
    t.index ["user_exam_id"], name: "index_submissions_on_user_exam_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "plan_id", null: false
    t.uuid "price_id"
    t.uuid "user_id", null: false
    t.uuid "created_by_id", null: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean "auto_renew", default: true, null: false
    t.string "stripe_subscription_id"
    t.string "status"
    t.boolean "cancel_at_period_end", default: false, null: false
    t.datetime "canceled_at"
    t.string "cancel_reason"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "razorpay_subscription_id"
    t.string "razorpay_short_url"
    t.string "redeem_code"
    t.index ["created_by_id"], name: "index_subscriptions_on_created_by_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["price_id"], name: "index_subscriptions_on_price_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_order", default: 0
    t.index ["subject_id"], name: "index_topics_on_subject_id"
  end

  create_table "user_collection_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_collection_id", null: false
    t.uuid "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "user_collection_id"], name: "index_question_user_collections_on_question_and_collection", unique: true
    t.index ["question_id"], name: "index_user_collection_questions_on_question_id"
    t.index ["user_collection_id"], name: "index_user_collection_questions_on_user_collection_id"
  end

  create_table "user_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "curriculum_id", null: false
    t.string "collection_type", null: false
    t.string "title"
    t.string "description"
    t.integer "questions_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["curriculum_id"], name: "index_user_collections_on_curriculum_id"
    t.index ["user_id"], name: "index_user_collections_on_user_id"
  end

  create_table "user_exam_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_exam_id", null: false
    t.uuid "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_user_exam_questions_on_question_id"
    t.index ["user_exam_id", "question_id"], name: "index_user_exam_questions_on_user_exam_id_and_question_id", unique: true
    t.index ["user_exam_id"], name: "index_user_exam_questions_on_user_exam_id"
  end

  create_table "user_exams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.uuid "created_by_id", null: false
    t.uuid "subject_id", null: false
    t.boolean "is_public", default: false, null: false
    t.string "nanoid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_user_exams_on_created_by_id"
    t.index ["nanoid"], name: "index_user_exams_on_nanoid", unique: true
    t.index ["subject_id"], name: "index_user_exams_on_subject_id"
  end

  add_foreign_key "accounts", "accounts", column: "referred_by_id"
  add_foreign_key "accounts", "curriculums", column: "selected_curriculum_id"
  add_foreign_key "activities", "accounts", column: "user_id"
  add_foreign_key "activities", "exams"
  add_foreign_key "activities", "subjects"
  add_foreign_key "activity_papers", "activities"
  add_foreign_key "activity_papers", "papers"
  add_foreign_key "activity_questions", "activities"
  add_foreign_key "activity_questions", "questions"
  add_foreign_key "activity_topics", "activities"
  add_foreign_key "activity_topics", "topics"
  add_foreign_key "answers", "questions"
  add_foreign_key "challenge_questions", "challenges"
  add_foreign_key "challenge_questions", "questions"
  add_foreign_key "challenges", "subjects"
  add_foreign_key "daily_check_ins", "accounts", column: "user_id"
  add_foreign_key "exams", "papers"
  add_foreign_key "gift_cards", "accounts", column: "created_by_id"
  add_foreign_key "gift_cards", "plans"
  add_foreign_key "guess_word_submission_guesses", "guess_word_submissions"
  add_foreign_key "guess_word_submissions", "accounts", column: "user_id"
  add_foreign_key "guess_word_submissions", "guess_words"
  add_foreign_key "guess_words", "subjects"
  add_foreign_key "papers", "subjects"
  add_foreign_key "point_activities", "accounts"
  add_foreign_key "prices", "plans"
  add_foreign_key "question_images", "questions"
  add_foreign_key "question_topics", "questions"
  add_foreign_key "question_topics", "topics"
  add_foreign_key "questions", "exams"
  add_foreign_key "questions", "subjects"
  add_foreign_key "referral_activities", "accounts", column: "user_id"
  add_foreign_key "saved_user_exams", "accounts", column: "user_id"
  add_foreign_key "saved_user_exams", "user_exams"
  add_foreign_key "sessions", "accounts"
  add_foreign_key "stripe_profiles", "accounts", column: "user_id"
  add_foreign_key "subjects", "curriculums"
  add_foreign_key "submission_answers", "accounts", column: "user_id"
  add_foreign_key "submission_answers", "questions"
  add_foreign_key "submission_answers", "submissions"
  add_foreign_key "submissions", "accounts", column: "user_id"
  add_foreign_key "submissions", "challenges"
  add_foreign_key "submissions", "user_exams"
  add_foreign_key "subscriptions", "accounts", column: "created_by_id"
  add_foreign_key "subscriptions", "accounts", column: "user_id"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "prices"
  add_foreign_key "topics", "subjects"
  add_foreign_key "user_collection_questions", "questions"
  add_foreign_key "user_collection_questions", "user_collections"
  add_foreign_key "user_collections", "accounts", column: "user_id"
  add_foreign_key "user_collections", "curriculums"
  add_foreign_key "user_exam_questions", "questions"
  add_foreign_key "user_exam_questions", "user_exams"
  add_foreign_key "user_exams", "accounts", column: "created_by_id"
  add_foreign_key "user_exams", "subjects"
end
