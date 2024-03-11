class GameUpdatesChannel < ApplicationCable::Channel
  def subscribed
    game = Game.find(params[:game_id])
    puts "subscribing to game_updates for game #{game.id}"
    stream_from "game_updates #{game.id}"
    # stream_for current_user.player
    # stream_from "game_updates"

  end

  def unsubscribed
    # Rails.logger.info "User #{current_user.email} unsubscribed from game_updates channel"
    puts "Unsubscribed from game_updates channel"
    # Any cleanup needed when channel is unsubscribed
  end

end
