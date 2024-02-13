class Player < ApplicationRecord
  has_many :cards
  has_many :bonus_tokens
  has_many :tokens
  belongs_to :game
end
