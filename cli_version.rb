TOKENS = {
  diamond_tokens: [7,6,5,4,3],
  gold_tokens: [7,6,5,4,3],
  silver_tokens: [7,6,5,4,3],
  spice_tokens: [5,4,3,2,2,1,1],
  cloth_tokens: [5,4,3,2,2,1,1],
  leather_tokens: [5,4,3,2,2,1,1,1,1,1],
}


BONUS_TOKENS = {
  trade_five_tokens: [10,9,8,8,8].shuffle,
  trade_four_tokens: [6,6,5,4,4,4].shuffle,
  trade_three_tokens: [3,3,2,2,1,1,1].shuffle
}

MASTER_DECK = [
  *Array.new(6, 'diamond'),
  *Array.new(6, 'gold'),
  *Array.new(6, 'silver'),
  *Array.new(8, 'spice'),
  *Array.new(8, 'cloth'),
  *Array.new(10, 'leather'),
  *Array.new(8, 'camel')
].shuffle

game_cards = [
player_one_hand = {
  camels: 0,
  hand: ["diamond"],
  tokens:[]
},
player_two_hand= {
  camels: 0,
  hand: ["gold"],
  tokens:[]
},
market = ['camel', 'camel', 'camel']
]


# game methods
def deal_cards(game_cards)
  2.times do
    game_cards[2] << MASTER_DECK.pop
  end
  5.times do
    card = MASTER_DECK.pop
    game_cards[0][:hand] << card unless card == 'camel'
    game_cards[0][:camels] += 1 if card == 'camel'

    card = MASTER_DECK.pop
    game_cards[1][:hand] << card unless card == 'camel'
    game_cards[1][:camels] += 1 if card == 'camel'
  end
  return game_cards
end

def refresh_market(game_cards)
  puts "number of cards in market #{game_cards[2].length}"
  num_of_cards = 5 - game_cards[2].length
  puts "number of cards to be added #{num_of_cards}"
  num_of_cards.times do
    game_cards[2] << MASTER_DECK.pop
  end
  puts "number of cards in market is now #{game_cards[2].length}"
  return game_cards #returning game_cards so that the new market can be used in the turn method
end

# add rule to prevent taking a camel, because you can only take all camels
def take_card(game_cards, player, num=1)
index = player - 1
  num.times do
    puts "Which card would you like to take? #{game_cards[2]}/n please type card 1/2/3/4/5"
    take_card = gets.chomp.to_i
      if take_card == 1
        game_cards[index][:hand] << game_cards[2].shift
      elsif take_card == 2
        game_cards[index][:hand] << game_cards[2].delete_at(1)
      elsif take_card == 3
        game_cards[index][:hand] << game_cards[2].delete_at(2)
      elsif take_card == 4
        game_cards[index][:hand] << game_cards[2].delete_at(3)
      elsif take_card == 5
        game_cards[index][:hand] << game_cards[2].delete_at(4)
      else
        puts "please choose a valid option"
      end
  end
  puts "your hand is now #{game_cards[index][:hand]}"
  puts "your herd is now #{game_cards[index][:camels]}"
  puts "the market is now #{game_cards[2]}"
  return game_cards
end

# add rule to prevent out of bounds error if player chooses a number greater than the length of their hand
def player_cards_to_market(game_cards, player, num)
  puts "player_cards_to_market"
  index = player - 1
  puts game_cards[index][:camels]
  num.times do
    if game_cards[index][:camels] > 0
      puts "you have #{game_cards[index][:camels]} camels. Would you like to exchange a camel for a card? [y/n]"
      choice = gets.chomp
      if choice == 'y'
        game_cards[index][:camels] -= 1
        game_cards[2] << 'camel'
      elsif choice == 'n'
        puts "you have chosen not to exchange a camel for a card"
        puts "which of your cards would you like to exchange for a card from the market? #{game_cards[index][:hand]}\n please type card 1 - 7 depending on the size of your hand"
        card_to_market = gets.chomp.to_i
        game_cards[2] << game_cards[index][:hand].delete_at(card_to_market - 1)
      else
        puts "please choose a valid option"
      end
    else
      puts "which of your cards would you like to exchange for a card from the market? #{game_cards[index][:hand]}\n please type card 1 - 7 depending on the size of your hand"
      card_to_market = gets.chomp.to_i
      game_cards[2] << game_cards[index][:hand].delete_at(card_to_market - 1)
    end
  end
end

def take_all_camels(game_cards, player)
index = player - 1
  puts "You have chosen to take all the camels"
  number_of_camels = game_cards[2].count('camel')

  game_cards[2].each_with_index do |card, index|
    if card == 'camel'
      game_cards[2].delete_at(index)
    end
  end
  game_cards[index][:camels] += number_of_camels
  puts "market is now #{game_cards[2]}"
  return game_cards
end

# add reminder that they cannot take camels with this option
def take_multiple_cards(game_cards, player=1)
  puts "You have chosen to take multiple cards and you will have to exchange cards from your hand"
  puts "how many cards would you like to take from the market?"
  number = gets.chomp.to_i
  take_card(game_cards, player, number)
  puts "you took #{number} cards from the market and you have to exchange #{number} cards from your hand"
  player_cards_to_market(game_cards, 1, number)
  return game_cards
end

def sell_cards_rule_check(selection, game_cards, player)
  index = player - 1
  if selection == 'camel'
    puts "you cannot sell camels"
    sell_cards(game_cards, player)
  elsif TOKENS[:"#{selection}_tokens"].length == 0
    puts "there are no #{selection} tokens left"
    sell_cards(game_cards, player)
  elsif selection == 'diamond' && game_cards[index][:hand].count('diamond') < 2 || selection == 'gold' && game_cards[index][:hand].count('gold') < 2 || selection == 'silver' && game_cards[index][:hand].count('silver') < 2
    puts "you cannot sell less than 2 #{selection} cards"
    sell_cards(game_cards, player)
    return game_cards
  end
end

def sell_high_value_card(game_cards, player, selection)
  puts "you have chosen to sell a high value card"
  puts "how many #{selection} cards would you like to sell?"
  number = gets.chomp.to_i
  if number < 2
    puts "you cannot sell less than 2 #{selection} cards"
    sell_high_value_card(game_cards, player, selection)
  else
    puts "you have chosen to sell #{number} #{selection} cards"
    number.times do
      puts "counter is #{counter}"
    game_cards[player - 1][:hand].delete_at(game_cards[player - 1][:hand].index(selection))
    game_cards[player - 1][:tokens] << TOKENS[:"#{selection}_tokens"].shift
    puts "your tokens are now #{game_cards[player - 1][:tokens]}"
    puts "the market is now #{game_cards[2]}"
    puts "your hand is now #{game_cards[player - 1][:hand]}"
    puts "your herd is now #{game_cards[player - 1][:camels]}"
    end
  end
  print "your tokens are now #{game_cards[player - 1][:tokens]}"
  print "your hand is now #{game_cards[player - 1][:hand]}"
  return game_cards
end
# add rule to deal with out of bounds error if player chooses a number greater than the length of their hand or market
def sell_cards(game_cards, player)
index = player - 1
  new_tokens = []
  trade_cards = []
  bonus_tokens = []
  puts "how many cards would you like to sell?"
  number = gets.chomp.to_i
  # add rule to prevent player from choosing a number that is not an integer
  # if number.is_a?(Integer) == false
  #    print "please choose a number"
  #     sell_cards(game_cards, player)
  number.times do
    puts "choose a card to sell from your hand  #{game_cards[index][:hand]}\n please type card 1 - 7 depending on the size of your hand"
    trade_card = gets.chomp.to_i - 1
    selection = game_cards[index][:hand][trade_card]
    if selection == 'diamond' || selection == 'gold' || selection == 'silver'
      sell_high_value_card(game_cards, player, selection)
      return game_cards
    else
      sell_cards_rule_check(selection, game_cards, player)
      game_cards[index][:hand].delete_at(trade_card)
      trade_cards << selection
      # add try - catch to allow player to buy one token with 2 cards if there are no tokens left without breaking the game
      new_token = TOKENS[:"#{selection}_tokens"].shift
      new_tokens << new_token
    end
  end
  diamond_tokens = trade_cards.count("diamond")
  gold_tokens = trade_cards.count("gold")
  silver_tokens = trade_cards.count("silver")
  spice_tokens = trade_cards.count("spice")
  cloth_tokens = trade_cards.count("cloth")
  leather_tokens = trade_cards.count("leather")
  bonus_tokens << diamond_tokens if diamond_tokens > 2
  bonus_tokens << gold_tokens if gold_tokens > 2
  bonus_tokens << silver_tokens if silver_tokens > 2
  bonus_tokens << spice_tokens if spice_tokens > 2
  bonus_tokens << cloth_tokens if cloth_tokens > 2
  bonus_tokens << leather_tokens if leather_tokens > 2
  bonus_tokens.sort!
  bonus_tokens.each do |token|
    new_tokens << BONUS_TOKENS[:trade_three_tokens].pop if token == 3 && BONUS_TOKENS[:trade_three_tokens].length > 0
    new_tokens << BONUS_TOKENS[:trade_four_tokens].pop if token == 4 && BONUS_TOKENS[:trade_four_tokens].length > 0
    new_tokens << BONUS_TOKENS[:trade_five_tokens].pop if token == 5 && BONUS_TOKENS[:trade_five_tokens.length] > 0
  end
  game_cards[index][:tokens] += new_tokens
  puts "your tokens are now #{game_cards[index][:tokens]}"
  puts "the market is now #{game_cards[2]}"
  puts "your hand is now #{game_cards[index][:hand]}"
  puts "your herd is now #{game_cards[index][:camels]}"
  return game_cards
end

# add rule for out of bounds error if player chooses a number greater than the length of their hand
def state_of_game(game_cards, player)
  index = player - 1
  puts "Player #{index + 1}:"
  puts "----------------------------------"
  if game_cards[index][:hand].length.nil?
    puts "Your hand: empty"
  else
    puts "Your hand: #{game_cards[index][:hand].sort!}"
  end
  puts "Your camels: #{game_cards[index][:camels]}"
  puts "Your tokens: #{game_cards[index][:tokens]}"
  total_cards = game_cards[index][:hand].length
  puts "you have #{total_cards} cards in your hand"
  puts "----------------------------------"
  puts "the market: #{game_cards[2]}"
  puts "----------------------------------"
  puts "tokens: \n Diamond: #{TOKENS[:diamond_tokens].length}\n Gold: #{TOKENS[:gold_tokens].length}\n Silver: #{TOKENS[:silver_tokens].length}\n Spice: #{TOKENS[:spice_tokens].length}\n Cloth: #{TOKENS[:cloth_tokens].length}\n Leather: #{TOKENS[:leather_tokens].length}"
  puts "----------------------------------"
  return total_cards
end

def turn(game_cards, player)

  players_total_cards = state_of_game(game_cards, player)
  if players_total_cards < 7
    puts "Would you like to:\n[a] Take one card from the market?\n[b] Take all the camels from the market (if there are camels)?\n[c] Take multiple cards from the market?\n[d] Sell cards for tokens?\nPlease type a/b/c/d"
    choice = gets.chomp
    if choice == 'a'
      take_card(game_cards, player, 1)
    elsif choice == 'b'
      take_all_camels(game_cards, player)
    elsif choice == 'c'
      take_multiple_cards(game_cards, player)
    elsif choice == 'd'
      sell_cards(game_cards, player)
    else
      puts "please choose a valid option"
      turn(game_cards, player)
    end
  else
    puts "you have 7 cards. you can either take all the camels from the market (if there are camels)?[b]\n,or sell cards for tokens?[d]\nPlease type b/d\n"
    choice = gets.chomp
    if choice == 'b'
      take_all_camels(game_cards, player)
    elsif choice == 'd'
      sell_cards(game_cards, player)
    else
      puts "please choose a valid option"
    end
  end
  empty_arrays = TOKENS.values.count(&:empty?)
  if empty_arrays >= 3
    score(game_cards)
  else
    refresh_market(game_cards) if game_cards[2].length < 5
    puts "----------------------------------"
    puts "your hand is now #{game_cards[player - 1][:hand]}"
    puts "your herd is now #{game_cards[player - 1][:camels]}"
    puts "----------------------------------"
    puts "next players turn, please pass the computer to the next player"
    puts "----------------------------------"
    puts "----------------------------------"
    return game_cards
  end
end

def score(game_cards)
  puts "game over:either there are 3 empty token arrays or the master deck is empty"
  player_one_token_total = game_cards[0][:tokens].inject(0, :+)
  player_two_token_total = game_cards[1][:tokens].inject(0, :+)
  player_one_camels = game_cards[0][:camels]
  player_two_camels = game_cards[1][:camels]
    if player_one_camels > player_two_camels
  player_one_score = player_one_token_total + 5
    elsif player_two_camels > player_one_camels
  player_two_score = player_two_token_total + 5
    else
      puts "no one gets the camel bonus because both players have the same number of camels"
    end
  puts "player one score is #{player_one_score}"
  puts "player two score is #{player_two_score}"
  puts "the winner is player one" if player_one_score > player_two_score
  puts "the winner is player two" if player_two_score > player_one_score
  puts "the game is a draw" if player_one_score == player_two_score
  return false
end
# game play
deal_cards(game_cards)
play = true
while MASTER_DECK.length > 0 and play
  empty_arrays = TOKENS.values.count(&:empty?)
  play = score(game_cards) if empty_arrays >= 3
  break unless play
  turn(game_cards, 1)
  empty_arrays = TOKENS.values.count(&:empty?)
  play = score(game_cards) if empty_arrays >= 3
  break unless play
  turn(game_cards, 2)
  empty_arrays = TOKENS.values.count(&:empty?)
  play = score(game_cards) if empty_arrays >= 3
  empty_arrays = TOKENS.values.count(&:empty?)
end
