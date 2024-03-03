class GameUpdatesChannel < ApplicationCable::Channel
  def subscribed
    game = Game.find(params[:game_id])
    stream_from "game_updates #{game.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed

  end

end
