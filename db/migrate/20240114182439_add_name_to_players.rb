class AddNameToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :name, :string
  end
end
