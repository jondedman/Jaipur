class CreateBonusTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :bonus_tokens do |t|
      t.string :type
      t.integer :value
      t.references :player, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
