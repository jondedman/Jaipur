require "application_system_test_case"

class GamesTest < ApplicationSystemTestCase
  setup do
    @game = games(:one)
  end

  test "visiting the index" do
    visit games_url
    assert_selector "h1", text: "Games"
  end

  test "should create game" do
    visit games_url
    click_on "New game"

    fill_in "Current round", with: @game.current_round
    fill_in "Discard pile", with: @game.discard_pile
    fill_in "Draw pile", with: @game.draw_pile
    fill_in "Game winner", with: @game.game_winner_id
    fill_in "Market", with: @game.market_id
    fill_in "Player turn", with: @game.player_turn_id
    fill_in "Round winner", with: @game.round_winner_id
    fill_in "Status", with: @game.status
    click_on "Create Game"

    assert_text "Game was successfully created"
    click_on "Back"
  end

  test "should update Game" do
    visit game_url(@game)
    click_on "Edit this game", match: :first

    fill_in "Current round", with: @game.current_round
    fill_in "Discard pile", with: @game.discard_pile
    fill_in "Draw pile", with: @game.draw_pile
    fill_in "Game winner", with: @game.game_winner_id
    fill_in "Market", with: @game.market_id
    fill_in "Player turn", with: @game.player_turn_id
    fill_in "Round winner", with: @game.round_winner_id
    fill_in "Status", with: @game.status
    click_on "Update Game"

    assert_text "Game was successfully updated"
    click_on "Back"
  end

  test "should destroy Game" do
    visit game_url(@game)
    click_on "Destroy this game", match: :first

    assert_text "Game was successfully destroyed"
  end
end
