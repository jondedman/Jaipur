class RenameTypeInTokens < ActiveRecord::Migration[7.0]
  def change
    rename_column :tokens, :type, :token_type
  end
end
