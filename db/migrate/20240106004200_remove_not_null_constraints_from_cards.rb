class RemoveNotNullConstraintsFromCards < ActiveRecord::Migration[7.0]
  def change
    change_column_null :cards, :player_id, true
    change_column_null :cards, :market_id, true
    change_column_null :cards, :discard_pile_id, true
  end
end
