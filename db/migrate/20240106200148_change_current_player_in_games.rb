class ChangeCurrentPlayerInGames < ActiveRecord::Migration[7.0]
  def change
    change_column_null :games, :current_player_id, true
  end
end
