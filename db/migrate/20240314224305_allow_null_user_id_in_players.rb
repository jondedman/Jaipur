class AllowNullUserIdInPlayers < ActiveRecord::Migration[7.0]
  def change
    change_column_null :players, :user_id, true
  end
end
