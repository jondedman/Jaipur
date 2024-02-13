class RenameTypeInCards < ActiveRecord::Migration[7.0]
  def change
    rename_column :cards, :type, :card_type
  end
end
