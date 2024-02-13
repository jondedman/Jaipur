class AddMarketIdToBonusTokens < ActiveRecord::Migration[7.0]
  def change
    add_reference :bonus_tokens, :market, null: false, foreign_key: true
  end
end
