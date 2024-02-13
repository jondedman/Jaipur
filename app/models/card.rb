class Card < ApplicationRecord
  belongs_to :player, optional: true
  belongs_to :game
  belongs_to :market, optional: true
  belongs_to :discard_pile, optional: true
end
