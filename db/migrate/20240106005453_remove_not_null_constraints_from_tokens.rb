class RemoveNotNullConstraintsFromTokens < ActiveRecord::Migration[7.0]
  def change
    change_column_null :tokens, :player_id, true
    change_column_null :tokens, :market_id, true
  end
end
