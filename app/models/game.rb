class Game < ApplicationRecord
  attr_accessor :current_player
  has_many :players
  # accepts_nested_attributes_for :players, allows you to create a game and its players in one go and is normally used in conjunction with fields_for in the view.
  accepts_nested_attributes_for :players
  has_many :cards
  has_many :bonus_tokens
  has_many :tokens
  has_one :market
  has_one :discard_pile

  after_create_commit -> { broadcast_prepend_to "games", partial: "games/new_game", locals: { game: self }, target: "games" }
end
