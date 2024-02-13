json.extract! game, :id, :status, :player_turn_id, :current_round, :draw_pile, :discard_pile, :market_id, :game_winner_id, :round_winner_id, :created_at, :updated_at
json.url game_url(game, format: :json)
