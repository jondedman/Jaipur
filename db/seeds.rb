# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
puts "Destroying all records"
puts "Destroying all bonus tokens"
BonusToken.destroy_all
puts "Destroying all tokens"
Token.destroy_all
puts "Destroying all cards"
Card.destroy_all
puts "Destroying all markets"
Market.destroy_all
puts "Destroying all discard piles"
DiscardPile.destroy_all

ActiveRecord::Base.connection.disable_referential_integrity do
  puts "Destroying all players"
  Player.destroy_all
  puts "Destroying all games"
  Game.destroy_all
end

puts "All records destroyed"
