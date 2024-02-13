class AddCurrentPlayerToGames < ActiveRecord::Migration[7.0]

  def change
    add_reference :games, :current_player, null: false, foreign_key: { to_table: :players }
  end
end
