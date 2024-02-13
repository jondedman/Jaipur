class AddTradeCounterToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :trade_counter, :integer
  end
end
