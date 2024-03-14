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

ActiveRecord::Schema[7.0].define(version: 2024_03_14_224305) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bonus_tokens", force: :cascade do |t|
    t.string "bonus_token_type"
    t.integer "value"
    t.bigint "player_id"
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "market_id"
    t.index ["game_id"], name: "index_bonus_tokens_on_game_id"
    t.index ["market_id"], name: "index_bonus_tokens_on_market_id"
    t.index ["player_id"], name: "index_bonus_tokens_on_player_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "card_type"
    t.bigint "player_id"
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "market_id"
    t.bigint "discard_pile_id"
    t.index ["discard_pile_id"], name: "index_cards_on_discard_pile_id"
    t.index ["game_id"], name: "index_cards_on_game_id"
    t.index ["market_id"], name: "index_cards_on_market_id"
    t.index ["player_id"], name: "index_cards_on_player_id"
  end

  create_table "discard_piles", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_discard_piles_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "current_player_id"
    t.index ["current_player_id"], name: "index_games_on_current_player_id"
  end

  create_table "markets", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_markets_on_game_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score"
    t.bigint "game_id", null: false
    t.integer "trade_counter"
    t.string "name"
    t.bigint "user_id"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "token_type"
    t.integer "value"
    t.bigint "player_id"
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "market_id"
    t.index ["game_id"], name: "index_tokens_on_game_id"
    t.index ["market_id"], name: "index_tokens_on_market_id"
    t.index ["player_id"], name: "index_tokens_on_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bonus_tokens", "games"
  add_foreign_key "bonus_tokens", "markets"
  add_foreign_key "bonus_tokens", "players"
  add_foreign_key "cards", "discard_piles"
  add_foreign_key "cards", "games"
  add_foreign_key "cards", "markets"
  add_foreign_key "cards", "players"
  add_foreign_key "discard_piles", "games"
  add_foreign_key "games", "players", column: "current_player_id"
  add_foreign_key "markets", "games"
  add_foreign_key "players", "games"
  add_foreign_key "players", "users"
  add_foreign_key "tokens", "games"
  add_foreign_key "tokens", "markets"
  add_foreign_key "tokens", "players"
end
