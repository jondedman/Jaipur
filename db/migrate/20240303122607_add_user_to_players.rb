class AddUserToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_reference :players, :user, null: false, foreign_key: true
  end
end
