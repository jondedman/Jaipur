class AddMarketIdAndDiscardPileIdToTokens < ActiveRecord::Migration[7.0]
  def change
    add_reference :tokens, :market, null: false, foreign_key: true
    add_reference :tokens, :discard_pile, null: false, foreign_key: true
  end
end
