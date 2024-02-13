require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:one)
  end

  test "should get index" do
    get games_url
    assert_response :success
  end

  test "should get new" do
    get new_game_url
    assert_response :success
  end

  test "should create game" do
    assert_difference("Game.count") do
      post games_url, params: { game: { current_round: @game.current_round, discard_pile: @game.discard_pile, draw_pile: @game.draw_pile, game_winner_id: @game.game_winner_id, market_id: @game.market_id, player_turn_id: @game.player_turn_id, round_winner_id: @game.round_winner_id, status: @game.status } }
    end

    assert_redirected_to game_url(Game.last)
  end

  test "should show game" do
    get game_url(@game)
    assert_response :success
  end

  test "should get edit" do
    get edit_game_url(@game)
    assert_response :success
  end

  test "should update game" do
    patch game_url(@game), params: { game: { current_round: @game.current_round, discard_pile: @game.discard_pile, draw_pile: @game.draw_pile, game_winner_id: @game.game_winner_id, market_id: @game.market_id, player_turn_id: @game.player_turn_id, round_winner_id: @game.round_winner_id, status: @game.status } }
    assert_redirected_to game_url(@game)
  end

  test "should destroy game" do
    assert_difference("Game.count", -1) do
      delete game_url(@game)
    end

    assert_redirected_to games_url
  end
end
