class CreateMarkets < ActiveRecord::Migration[7.0]
  def change
    create_table :markets do |t|
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
