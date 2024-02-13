class RemoveDiscardPileFromTokens < ActiveRecord::Migration[7.0]
  def change
    remove_reference :tokens, :discard_pile, index: true, foreign_key: true
  end
end
