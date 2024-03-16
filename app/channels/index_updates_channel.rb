class IndexUpdatesChannel < ApplicationCable::Channel
  def subscribed
    puts "subscribing to index_updates"
    stream_for "index_updates"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
