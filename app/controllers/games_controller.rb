class GamesController < ApplicationController
  before_action :set_game, only: [:create_player, :join, :change_turn, :show, :take_card, :refresh_market, :take_multiple_cards, :hand_to_market, :trade_in_tokens, :calculate_bonus_tokens, :end_turn, :take_all_camels, :hand_to_discard_pile, :game_over, :multiple_cards_to_market, :high_value_trade_in, :setup_game, :players_details]
  before_action :set_current_player, only: [:change_turn, :show, :trade_in_tokens, :multiple_cards_to_market, :take_multiple_cards, :take_card, :take_all_camels, :calculate_bonus_tokens, :update_card_ids, :turn_check]
  before_action :players_details, only: [:join, :show, :trade_in_tokens, :high_value_trade_in, :take_card, :take_all_camels, :update_card_ids, :multiple_cards_to_market, :take_multiple_cards, :calculate_bonus_tokens, :turn_check]
  before_action :turn_check, only: [:take_card, :take_all_camels, :take_multiple_cards, :trade_in_tokens, :hand_to_market, :multiple_cards_to_market]
  before_action :game_over_check, only: [:take_card, :take_all_camels, :take_multiple_cards, :trade_in_tokens, :hand_to_market, :multiple_cards_to_market]

  def index
    # I need to render this message as part of the link back to home page instead of the index. I need to overwrite the ingame messages with the general game message.
    # general_game_message("Welcome to Jaipur. Enter the game id to start playing or create a new game.")
    # I can still use the below in the index to display other games
    @games = Game.order(created_at: :desc).limit(5)
    @game = Game.new
  end

  def new
    @games = Game.order(created_at: :desc).limit(5)
    puts "Creating new game"
    @game = Game.new
  end

  def create
    if current_user == nil
      general_game_message("You must be logged in to create a game")
      return
    end
    puts "in create method"
    @games = Game.order(created_at: :desc).limit(5)
    @game = Game.new
    if @game.save
      market = Market.create!(game: @game)
      puts "Market created with id #{market.id}"
      discard_pile = DiscardPile.create!(game: @game)
      puts "Discard pile created with id #{discard_pile.id}"
      seed_cards(@game)
      puts "Cards seeded"
      seed_tokens(@game)
      puts "Tokens seeded"
      seed_bonus_tokens(@game)
      puts "Bonus tokens seeded"
      populate_market(@game)
      puts "Market populated"
      puts "creating players"
      2.times { @game.players.create }
      puts "players created"
      populate_initial_hands(@game.players.first, @game.players.second)
      puts "Initial hands populated"
      initialise_scores(@game.players.first, @game.players.second)
      puts "Scores initialised"
      puts "assigning current player"
      @game.update!(current_player_id: @game.players.first.id)
      puts "current player assigned"
      puts "Game setup complete"
      IndexUpdatesChannel.broadcast_to("index_updates", { message: "New game created" })
      # GameUpdatesChannel.broadcast_to(@game, { message: "New game created" })
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to games_path }
      end
    else
      puts "Game creation failed"
      @game = Game.new
      render :new
    end
  end

  def join_game
    puts "in update method"
    # if @game == nil
    #   redirect_to action: :index
    #   return
    # end
    id = params[:game_id]
    @game = Game.find(id)
    player = @game.players.find_by(user: nil)
    if player
      player.update!(user: current_user, name: current_user.email)
      redirect_to game_path(@game)
    else
      flash[:alert] = "Game is full"
      redirect_to games_path
    end
  end

  def change_turn
    puts "Changing turn"
    @current_player = @current_users_player.id == @game.players.second.id ? @game.players.first : @game.players.second
    @game.update!(current_player_id: @current_player.id)
    refresh_market()
    name = @current_player.name
    GameUpdatesChannel.broadcast_to(@game, { redirect: game_path(@game) })
    render_game_and_message()
    puts "Turn changed"
  end

  def show
    @game = Game.find(params[:id])
    @market_tokens = @game.market.tokens
    puts "Showing game"
    if game_over()
      final_scoring()
    end_turn()
    else
    general_game_message("#{@current_player.name}'s turn")
    end
  end

  def final_scoring
    @player1, @player2 = @game.players.order(:id)
    player1_token_total = @player1.tokens.sum(:value)
    puts "Player 1 token total: #{player1_token_total}"
    player2_token_total = @player2.tokens.sum(:value)
    puts "Player 2 token total: #{player2_token_total}"
    player1_bonus_token_total = @player1.bonus_tokens.sum(:value)
    puts "Player 1 bonus token total: #{player1_bonus_token_total}"
    player2_bonus_token_total = @player2.bonus_tokens.sum(:value)
    puts "Player 2 bonus token total: #{player2_bonus_token_total}"
    player1_herd_total = @player1.cards.where(card_type: "Camel").count
    puts "Player 1 herd total: #{player1_herd_total}"
    player2_herd_total = @player2.cards.where(card_type: "Camel").count
    puts "Player 2 herd total: #{player2_herd_total}"
    camel_bonus = player1_herd_total > player2_herd_total ? 'player1' : 'player2'
    player1_total = player1_token_total + player1_bonus_token_total + (player1_herd_total > player2_herd_total ? 5 : 0)
    player2_total = player2_token_total + player2_bonus_token_total + (player2_herd_total > player1_herd_total ? 5 : 0)
    @player1.update!(score: player1_total)
    @player2.update!(score: player2_total)
    if player1_total == player2_total
      winner = "It's a draw! No one"
    else
    winner = player1_total > player2_total ? @player1.name : @player2.name
    end
    general_game_message("Game over! #{@player1.name} scored #{player1_total} points. #{@player2.name} scored #{player2_total} points. #{winner} wins!")
  end

  def game_over
    puts "Checking if game is over"
    @player1, @player2 = @game.players.order(:id)
    cards_left = @game.cards.where(player_id: nil, market_id: nil, discard_pile_id: nil)
    puts "Cards left: #{cards_left.count}"
    condition1 = cards_left.count < 5
    goods_count = @game.market.tokens.where(token_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"]).group(:token_type).count.values
    empty_tokens = goods_count.select { |token| token > 0 }
    condition2 = empty_tokens.length <= 3
    if condition1 || condition2
      final_scoring()
      puts "Game over"
      return true
    else
      return false
    end
  end

  def refresh_market
    puts "Refreshing market"
    while @game.market.cards.count < 5
    card = Card.where(game: params[:id], player: nil, market: nil, discard_pile: nil).sample
    break if card.nil?
    card.update!(market_id: @game.market.id)
    @game.market.cards << card if card
    end
    puts "Market refreshed"
  end


  def update_card_ids(card)
    puts "Updating card ids"
    puts card.inspect
    card.update!(market_id: nil, player_id: @current_users_player.id)
    puts card.inspect
    puts "Card ids updated"
  end

  def update_token_ids(token)
    token.update!(player_id: @current_player.id, market_id: nil)
  end

  def reset_trade_counter
    @current_users_player.update!(trade_counter: 0)
  end

  def calculate_bonus_tokens(total_trade_counter)
    puts "Calculating bonus tokens again"
    puts "Total trade counter: #{total_trade_counter}"
    puts "Current player trade counter: #{@current_users_player.name}"

    if total_trade_counter == 5
      bonus = @game.market.bonus_tokens.where(bonus_token_type: "trade_five_tokens").first
      bonus.update!(player_id: @current_users_player.id, market_id: nil)
    elsif total_trade_counter == 4
      bonus = @game.market.bonus_tokens.where(bonus_token_type: "trade_four_tokens").first
      bonus.update!(player_id: @current_users_player.id, market_id: nil)
    elsif total_trade_counter == 3
      bonus = @game.market.bonus_tokens.where(bonus_token_type: "trade_three_tokens").first
      bonus.update!(player_id: @current_users_player.id, market_id: nil)
    else
      return
    end
  end

  def hand_to_market()
    if @game.market.cards.count == 5
      change_turn()
    else
    card = Card.find(params[:card_id])
    card.update!(market_id:@game.market.id, player_id: nil)
    render_game_and_message()
    end
  end

  def multiple_cards_to_market()
    card_ids = params[:player_card_ids]
    camels_to_exchange = card_ids.select { |card_id| Card.find(card_id).card_type == "Camel" }
    goods_to_exchange = card_ids.select { |card_id| Card.find(card_id).card_type != "Camel" }
    balance = @current_players_cards.count - goods_to_exchange.count
    if card_ids.nil?
      render_game_and_message("You must choose at least one card to exchange")
      return
    elsif card_ids.length + @game.market.cards.count > 5
      render_game_and_message("You cannot exchange more cards than there are spaces in the market")
      return
    elsif balance > 7
      render_game_and_message("You cannot have more than 7 cards in your hand")
      return
    end
    if @game.market.cards.count == 5
      render_game_and_message("Market is full, take cards from market first")
      else
        for card_id in card_ids
          card = Card.find(card_id)
          card.update!(market_id:@game.market.id, player_id: nil)
        end
        if @game.market.cards.count < 5
          render_game_and_message("You must take cards from your hand to fill the market")
        else
        end_turn()
        end
    end
  end

  def hand_to_discard_pile(token)
    current_players_cards = @game.cards.where(player_id: @current_player.id)
    card_to_discard = current_players_cards.find { |card| card.card_type == token.token_type }
    if card_to_discard.nil?
      puts "No cards of that type"
      token.update!(player_id: nil, market_id: @game.market.id)  # return token to market
      change_turn()
    else
      card_to_discard.update!(player_id: nil, discard_pile_id: @game.discard_pile.id)
    end
  end

def count_matching_cards(card_type)
  current_players_cards = @game.cards.where(player_id: @current_player.id)
  matching_cards = current_players_cards.where(card_type: card_type)
  return if matching_cards.empty?
  matching_cards.each do |card|
    card.update!(player_id: nil, discard_pile_id: @game.discard_pile.id)
    token_to_update = @game.market.tokens.find { |token| token.token_type == card_type }
    update_card_ids(token_to_update)
  end

end

  def take_card
    card = Card.find(params[:card_id])
    if @current_players_cards.count >= 7
      render_game_and_message("You have 7 cards, you can buy some goods, or exchange some cards or take all camels")
    elsif
      card.card_type == "Camel"
      take_all_camels()
    elsif
      @game.market.cards.count < 5
      render_game_and_message("You must take cards from your hand to fill the market")
    else
      update_card_ids(card)
      refresh_market()
      end_turn()
  end
end

def camel_check(card_ids)
  card_ids.each do |card_id|
    card_to_check = Card.find(card_id)
    if card_to_check.card_type == "Camel"
      return true
    else
      return false
    end
  end
end

  def take_multiple_cards
      card_ids = params[:card_ids]
      if card_ids.nil? || card_ids.length < 2
        render_game_and_message("You must choose more than one card to exchange")
      elsif camel_check(card_ids)
        render_game_and_message("You cannot exchange camels. You can only take all camels")
      else
        card_ids.each do |card_id|
          card_to_update = Card.find(card_id)
          update_card_ids(card_to_update)
        end
        render_game_and_message("Now choose an equal number of cards from your hand to discard")
      end
  end

def take_all_camels
  puts "Taking all camels"
  if @game.market.cards.count < 5
    render_game_and_message("You cannot take camels.You must take cards from your hand to fill the market")
    return
  else
  camel_cards = @game.market.cards.where(card_type: "Camel")
  return if camel_cards.empty?
  camel_cards.each do |card|
    puts card.inspect
    update_card_ids(card)
  end
  refresh_market()
  end_turn()
end
end

def high_value_trade_in(token, matching_cards, matching_tokens = [])
  puts "High value trade in"
  matching_market_tokens = @game.market.tokens.where(token_type: token.token_type).to_a
  if token.token_type == "Diamond" && matching_cards.count < 2 || token.token_type == "Gold" && matching_cards.count < 2 || token.token_type == "Silver" && matching_cards.count < 2
    render_game_and_message("You need at least 2 cards to trade in diamonds, gold or silver")
  elsif token.token_type == "Diamond" && matching_cards.count >= 2 && matching_market_tokens.count == 1 || token.token_type == "Gold" && matching_cards.count >= 2 && matching_market_tokens.count == 1 || token.token_type == "Silver" && matching_cards.count >= 2 && matching_market_tokens.count == 1
    matching_cards.each do |card|
      card.update!(player_id: nil, discard_pile_id: @game.discard_pile.id)
    end
    matching_market_tokens.each do |token|
      token.update!(player_id: @current_player.id, market_id: nil)
    end
    raise "in high value trade in"
  end_turn()
  else
    matching_cards.each do |card|
      card.update!(player_id: nil, discard_pile_id: @game.discard_pile.id)
      token_to_update = matching_tokens.shift
      if token_to_update
        token_to_update.update!(player_id: @current_player.id, market_id: nil)
        @current_player.increment!(:trade_counter)
      end
    end
    calculate_bonus_tokens(@current_player.trade_counter)
    end_turn()
  end
  end

def trade_in_tokens
  puts "current player #{@current_player}"
  puts "current users player #{@current_users_player}"
  puts "@market.tokens #{@game.market.tokens}"
  puts "Trading in tokens"
  if @game.market.cards.count < 5
    render_game_and_message("You must take cards from your hand to fill the market")
    return
  end
  token = Token.find(params[:token_id])

  token_type = token.token_type
  card_type = token.token_type

  matching_cards = @current_players_cards.where(card_type: card_type)
  matching_tokens = @game.market.tokens.where(token_type: token_type).to_a
  return if matching_cards.empty?
  if token_type == "Diamond"  || token.token_type == "Gold" || token.token_type == "Silver"
    high_value_trade_in(token, matching_cards, matching_tokens)
  else
    matching_cards.each do |card|
      card.update!(player_id: nil, discard_pile_id: @game.discard_pile.id)
      token_to_update = matching_tokens.shift
      if token_to_update
        token_to_update.update!(player_id: @current_player.id, market_id: nil)
        @current_users_player.increment!(:trade_counter)
      end
    end
    calculate_bonus_tokens(@current_users_player.trade_counter)
    end_turn()
  end
end

def end_turn
  puts "Ending turn"
  if @game.market.cards.count < 5
    render_game_and_message("You must take cards from your hand to fill the market")
    return
  else
    reset_trade_counter()
    puts "checking if game is over"
    if game_over()
      puts "Game over"
      return
    else
    puts "Game not over"
    refresh_market()
    change_turn()
    puts "Turn ended"
    end
  end
end

def general_game_message(message)
  puts "General game message"
  flash[:game_notice] = message
  respond_to do |format|
    format.html
    format.turbo_stream do
      render turbo_stream: turbo_stream.update('game_updates', partial: 'game_updates', locals: { game_notice: flash[:game_notice] })
    end
  end
  GameUpdatesChannel.broadcast_to(@game, { message: message })
end
  private

  def seed_cards(game)
    puts "Seeding cards"
    # Define the types of cards and how many of each type there are
    card_types = {
      "Camel" => 11,
      "Leather" => 10,
      "Spice" => 8,
      "Cloth" => 8,
      "Silver" => 6,
      "Gold" => 6,
      "Diamond" => 6
    }
    card_types.each do |type, quantity|
      quantity.times do
        Card.create!(game: game, card_type: type, market: nil, player: nil, discard_pile: nil)
      end
    end
  end

  def seed_tokens(game)
    puts "Seeding tokens"
    # Define the types of tokens and how many of each type there are
    token_types = {
      Diamond: [7,6,5,4,3],
      Gold: [7,6,5,4,3],
      Silver: [7,6,5,4,3],
      Spice: [5,4,3,2,2,1,1],
      Cloth: [5,4,3,2,2,1,1],
      Leather: [5,4,3,2,2,1,1,1,1,1],
    }

    # Create the tokens
    token_types.each do |type, values|
      values.each do |value|
        Token.create!(game: game, token_type: type, value: value)
      end
    end
  end

  def seed_bonus_tokens(game)
    puts "Seeding bonus tokens"
    # Define the types of bonus tokens and how many of each type there are
    bonus_token_types = {
      trade_five_tokens: [10,9,8,8,8],
      trade_four_tokens: [6,6,5,4,4,4],
      trade_three_tokens: [3,3,2,2,1,1,1]
    }

    # Create the bonus tokens
    bonus_token_types.each do |type, values|
      values.each do |value|
        BonusToken.create!(game: game, bonus_token_type: type, value: value)
      end
    end
  end

  def populate_initial_hands(player1, player2)
    puts "Populating initial hands"
    players = [player1, player2]
    players.each do |player|
      cards = Card.where(game: player.game, player: nil, market: nil).sample(5)
      cards.each do |card|
        card.update!(player_id: player.id)
      end
    end
  end

  def populate_market(game)
    puts "Populating market"
    market = game.market
    camels = Card.where(game: game, player: nil, card_type: "Camel").sample(2)
    cards = Card.where(game: game, player: nil, card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"]).sample(3)
    tokens = Token.where(game: game, player: nil).all
    bonus_tokens = BonusToken.where(game: game, player: nil).all
    (camels + cards).each do |card|
      card.update!(market_id: market.id)
    end
    market.tokens = tokens
    market.bonus_tokens = bonus_tokens
    market.save!
  end

  def initialise_scores(player1, player2)
    puts "Initialising scores"
    players = [player1, player2]
    players.each do |player|
      player.score = 0
      player.save!
    end
  end

  def set_game
    @game = Game.find(params[:id])
  end

  def set_current_player
    puts "Setting current player"
    @current_player = @game.players.find { |player| player.id == @game.current_player_id}
  end

def players_details
puts "Setting players details"
  @current_users_player = @game.players.find_by(user: current_user)
  puts "current users player #{@current_users_player}"
  @current_players_cards = @current_users_player.cards.where(card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"])
  puts "current players cards #{@current_players_cards}"
  @current_players_herd = @current_users_player.cards.where(card_type: "Camel")
  @current_players_tokens = @current_users_player.tokens
  puts "current players tokens #{@current_players_tokens}"
  @current_players_bonus_tokens = @current_users_player.bonus_tokens
  puts "current players bonus tokens #{@current_players_bonus_tokens}"
  @opponents_player = @game.players.where.not(user: current_user).first
end

  def game_params
    params.require(:game).permit()
  end

  def render_game_and_message(message="#{@current_player.name}'s turn")
    puts "Rendering game and message"
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash_messages", partial: "flash_messages", locals: { notice: message }),
          turbo_stream.replace("game-#{@game.id}", partial: 'games/game', locals: { game: @game })
        ]
      end
      format.html { render :show }
    end
  end

def turn_check
  if @current_player.id != @current_users_player.id
    render_game_and_message("It's not your turn")
    return
  end
end

def game_over_check
  if game_over()
    return
  end
end
end
