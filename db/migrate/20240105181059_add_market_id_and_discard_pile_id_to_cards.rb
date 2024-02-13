class AddMarketIdAndDiscardPileIdToCards < ActiveRecord::Migration[7.0]
  def change
    add_reference :cards, :market, null: false, foreign_key: true
    add_reference :cards, :discard_pile, null: false, foreign_key: true
  end
end
