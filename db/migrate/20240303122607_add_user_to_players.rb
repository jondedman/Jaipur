# filepath: /Users/jondedman/code/twenty_four/Jaipur/db/migrate/20240303122607_add_user_to_players.rb
class AddUserToPlayers < ActiveRecord::Migration[7.0]
  def up
    # Add the user_id column
    add_reference :players, :user, null: true, foreign_key: true

    # Set a default user_id for existing records
    default_user = User.first || User.create!(email: 'default@example.com', password: 'password', password_confirmation: 'password')
    Player.where(user_id: nil).update_all(user_id: default_user.id)

    # Change the user_id column to not allow null values
    change_column_null :players, :user_id, false
  end

  def down
    # Optionally, you can revert the changes made in the up method
    default_user = User.find_by(email: 'default@example.com')
    Player.where(user_id: default_user.id).update_all(user_id: nil) if default_user

    # Remove the user_id column
    remove_reference :players, :user, foreign_key: true
  end
end
