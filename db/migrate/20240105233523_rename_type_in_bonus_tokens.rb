class RenameTypeInBonusTokens < ActiveRecord::Migration[7.0]
  def change
    rename_column :bonus_tokens, :type, :bonus_token_type
  end
end
