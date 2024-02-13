class RemoveNotNullConstraintsFromBonusTokens < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bonus_tokens, :player_id, true
    change_column_null :bonus_tokens, :market_id, true
  end
end
