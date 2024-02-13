class BonusToken < ApplicationRecord
  belongs_to :player, optional: true
  belongs_to :game
  belongs_to :market, optional: true
end
