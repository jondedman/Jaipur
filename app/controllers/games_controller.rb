class GamesController < ApplicationController
  before_action :set_game, only: [:change_turn, :show, :take_card, :refresh_market, :take_multiple_cards, :hand_to_market, :trade_in_tokens, :calculate_bonus_tokens, :end_turn, :take_all_camels, :hand_to_discard_pile, :game_over, :multiple_cards_to_market, :high_value_trade_in, :setup_game]
  before_action :set_current_player, only: [:set_game, :show, :take_card, :change_turn, :take_multiple_cards, :multiple_cards_to_market, :take_all_camels, :trade_in_tokens, :calculate_bonus_tokens]
  before_action :setup_game, only: [:show, :take_card, :hand_to_discard_pile, :end_turn, :change_turn, :trade_in_tokens, :calculate_bonus_tokens, :take_multiple_cards, :reset_trade_counter, :hand_to_market, :current_player, :take_all_camels, :game_over, :multiple_cards_to_market, :refresh_market, :high_value_trade_in]

  def index
    @games = Game.all
    @game = Game.new
    2.times { @game.players.build }
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def new
    @game = Game.new
    2.times { @game.players.build }
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      # Create a market
      market = Market.create!(game: @game)
      puts "Market created with id #{market.id}"
      discard_pile = DiscardPile.create!(game: @game)
      puts "Discard pile created with id #{discard_pile.id}"
      # Seed the database with cards, tokens, and bonus tokens
      seed_cards(@game)
      puts "Cards seeded"
      seed_tokens(@game)
      puts "Tokens seeded"
      seed_bonus_tokens(@game)
      puts "Bonus tokens seeded"
      # Populate the players' hands with their initial 5 cards
      populate_initial_hands(@game.players.first, @game.players.second)
      puts "Initial hands populated"
      initialise_scores(@game.players.first, @game.players.second)
      puts "Scores initialised"
      # Populate the market with cards, tokens, and bonus tokens
      populate_market(@game)
      puts "Market populated"
      puts "Game setup complete"
      @game.update!(current_player_id: @game.players.first.id)
      new_game = Game.new
      2.times { new_game.players.build }
      respond_to do |format|
        format.turbo_stream do
          turbo_stream.replace 'new_game_form', partial: 'games/game', locals: { game: @game }
        end
        format.html { redirect_to game_path(@game) }
      end
    else
      puts "Game creation failed"
      @game = Game.new
      2.times { @game.players.build }
      render :new
    end
  end

  def change_turn
    @current_player = @current_player.id == @player1.id ? @player2 : @player1
    @game.update!(current_player_id: @current_player.id)
    @current_players_cards = @current_player.cards.where(card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"])
    @current_players_herd = @current_player.cards.where(card_type: "Camel")

    refresh_market()
    name = @current_player.name
    render_game_and_message()
    # respond_to do |format|
    #   format.turbo_stream do
    #     render turbo_stream: [
    #       turbo_stream.replace("game-#{@game.id}", partial: 'games/game', locals: { game: @game }),
    #     ]
    #   end
    #   format.html { render :show }
    # end
  end

  def show
    respond_to do |format|
      format.html
      format.turbo_stream
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
    render_game_and_message("Game over! #{@player1.name} scored #{player1_total} points. #{@player2.name} scored #{player2_total} points. #{winner} wins!")
    return
  end

  def game_over
    @player1, @player2 = @game.players.order(:id)
    cards_left = @game.cards.where(player_id: nil, market_id: nil, discard_pile_id: nil)
    condition1 = cards_left.count == 0

    goods_count = @game.market.tokens.where(token_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"]).group(:token_type).count.values
    empty_tokens = goods_count.select { |token| token > 0 }
    condition2 = empty_tokens.length <= 3

    if condition1 || condition2
      final_scoring()
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
    puts @current_player.inspect
    puts card.inspect
    card.update!(market_id: nil, player_id: @current_player.id)
    puts card.inspect
    puts "Card ids updated"
  end

  def update_token_ids(token)
    token.update!(player_id: @current_player.id, market_id: nil)


  end

  def reset_trade_counter
    @current_player.update!(trade_counter: 0)
  end

  def calculate_bonus_tokens(total_trade_counter)

    if total_trade_counter == 5
      bonus = @game.market.bonus_tokens.where(bonus_token_type: "trade_five_tokens").first
      bonus.update!(player_id: @current_player.id, market_id: nil)
      # reset_trade_counter()
      # change_turn()
    elsif total_trade_counter == 4
      bonus = @game.market.bonus_tokens.where(bonus_token_type: "trade_four_tokens").first
      bonus.update!(player_id: @current_player.id, market_id: nil)
    elsif total_trade_counter == 3
      bonus = @game.market.bonus_tokens.where(bonus_token_type: "trade_three_tokens").first
      bonus.update!(player_id: @current_player.id, market_id: nil)
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
    @current_players_cards = @current_player.cards.where(card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"])
    card_ids = params[:player_card_ids]
    camels_to_exchange = card_ids.select { |card_id| Card.find(card_id).card_type == "Camel" }
    goods_to_exchange = card_ids.select { |card_id| Card.find(card_id).card_type != "Camel" }
    balance = @current_players_cards.count - goods_to_exchange.count
    if card_ids.nil?
      render_game_and_message("You must choose at least one card to exchange")
      # render_game()
      return
    elsif card_ids.length + @game.market.cards.count > 5
      render_game_and_message("You cannot exchange more cards than there are spaces in the market")
      # render_game()
      return
    elsif balance > 7
      render_game_and_message("You cannot have more than 7 cards in your hand")
      return
    end
    if @game.market.cards.count == 5
      render_game_and_message("Market is full, take cards from market first")
      # render_game()
      else
        for card_id in card_ids
          card = Card.find(card_id)
          card.update!(market_id:@game.market.id, player_id: nil)
        end
        if @game.market.cards.count < 5
          render_game_and_message("You must take cards from your hand to fill the market")
          # render_game()
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
    @current_players_cards = @current_player.cards.where(card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"])
    card = Card.find(params[:card_id])
    if @current_players_cards.count >= 7
      render_game_and_message("You have 7 cards, you can buy some goods, or exchange some cards or take all camels")
      # render_game()
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
    @current_players_cards = @current_player.cards.where(card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"])
    # needs renaming to current player card ids
      # player1_card_ids = params[:player1_card_ids]
      card_ids = params[:card_ids]

      if card_ids.nil? || card_ids.length < 2

        render_game_and_message("You must choose more than one card to exchange")
      #  render_game()
        # return
      # end
      elsif camel_check(card_ids)
        render_game_and_message("You cannot exchange camels. You can only take all camels")
        # return
      else
        card_ids.each do |card_id|
          card_to_update = Card.find(card_id)
          update_card_ids(card_to_update)
        end
      #  render_game()
        render_game_and_message("Now choose an equal number of cards from your hand to discard")
      end
  end

def take_all_camels
  puts "Taking all camels"

  puts @current_player.inspect
  if @game.market.cards.count < 5
    render_game_and_message("You cannot take camels.You must take cards from your hand to fill the market")
    # render_game()
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
  if @game.market.cards.count < 5
    render_game_and_message("You must take cards from your hand to fill the market")
    # render_game()
    return
  end
  token = Token.find(params[:token_id])

  token_type = token.token_type
  card_type = token.token_type
  current_players_cards = @game.cards.where(player_id: @current_player.id)
  matching_cards = current_players_cards.where(card_type: card_type)
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
        @current_player.increment!(:trade_counter)
      end
    end
    calculate_bonus_tokens(@current_player.trade_counter)
    end_turn()
  end
end

def end_turn
  puts "Ending turn"
  if @game.market.cards.count < 5
    render_game_and_message("You must take cards from your hand to fill the market")
    # Replace the redirect with a Turbo Stream update
    # respond_to do |format|
    #   format.turbo_stream { render turbo_stream: turbo_stream.replace("game-#{@game.id}", partial: 'games/game', locals: { game: @game }) }
    #   format.html { render :show }
    # end
    return
  else
    reset_trade_counter()
    return if game_over()
    refresh_market()
    change_turn()
    puts "Turn ended"
  end


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

    # Create the cards
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
    # puts "Camels: #{camels.inspect}"
    # puts "Cards: #{cards.inspect}"
    # puts "Tokens: #{tokens.inspect}"
    # puts "Bonus tokens: #{bonus_tokens.inspect}"

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

  def setup_game
    p "Setting up game"
    p "@game #{@game}"

    @player1, @player2 = @game.players.order(:id)
    p "@current_player #{@current_player}"
    @current_players_cards = @current_player.cards.where(card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"])
    p "@current_players_cards #{@current_players_cards}"
    @current_players_herd = @current_player.cards.where(card_type: "Camel")

    @hands = {
      @player1 => {
        cards: @player1.cards.where(card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"]),
        herd: @player1.cards.where(card_type: "Camel"),
        tokens: @player1.tokens,
        bonus_tokens: @player1.bonus_tokens
      },
      @player2 => {
        cards: @player2.cards.where(card_type: ["Leather", "Spice", "Cloth", "Silver", "Gold", "Diamond"]),
        herd: @player2.cards.where(card_type: "Camel"),
        tokens: @player2.tokens,
        bonus_tokens: @player2.bonus_tokens
      }
    }

    @market = {
      market_cards: @game.market.cards,
      diamond_tokens: @game.market.tokens.where(token_type: "Diamond").order(value: :desc),
      gold_tokens: @game.market.tokens.where(token_type: "Gold").order(value: :desc),
      silver_tokens: @game.market.tokens.where(token_type: "Silver").order(value: :desc),
      cloth_tokens: @game.market.tokens.where(token_type: "Cloth").order(value: :desc),
      spice_tokens: @game.market.tokens.where(token_type: "Spice").order(value: :desc),
      leather_tokens: @game.market.tokens.where(token_type: "Leather").order(value: :desc),
      trade_five_tokens: @game.market.bonus_tokens.where(bonus_token_type: "trade_five_tokens").shuffle,
      trade_four_tokens: @game.market.bonus_tokens.where(bonus_token_type: "trade_four_tokens").shuffle,
      trade_three_tokens: @game.market.bonus_tokens.where(bonus_token_type: "trade_three_tokens").shuffle
  }

    @scores = {
      @player1 => @player1.score,
      @player2 => @player2.score
    }
    @discard_pile = @game.discard_pile.cards
  end

  def set_current_player
    puts "Setting current player"
    @current_player = @game.players.find { |player| player.id == @game.current_player_id}
    puts "game #{@game}"
    puts "players #{@game.players.inspect }"
    puts "current player #{@current_player.inspect}"
    puts "current player id: #{@game.current_player_id}"
  end

  def game_params
    params.require(:game).permit(players_attributes: [:name])
  end


  # def render_game
  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream: [
  #         turbo_stream.replace("game-#{@game.id}", partial: 'games/game', locals: { game: @game }),
  #         turbo_stream.replace("flash_messages", partial: "flash_messages")
  #       ]
  #     end
  #     format.html { render :show }
  #   end
  # end

  # def render_message(message)
  #   flash[:notice] = "#{message}"

  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream: turbo_stream.replace("flash_messages", partial: "flash_messages")
  #     end
  #     format.html { redirect_to game_path(@game) }
  #   end
  # end

  def render_game_and_message(message="#{@current_player.name}'s turn")
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
end
