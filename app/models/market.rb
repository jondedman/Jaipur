class Market < ApplicationRecord
  belongs_to :game
  has_many :cards
  has_many :bonus_tokens
  has_many :tokens
end
