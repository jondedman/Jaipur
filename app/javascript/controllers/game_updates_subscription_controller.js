import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

// Connects to data-controller="game-updates-subscription"
export default class extends Controller {
	connect() {
		console.log("Connected to GameUpdatesSubscriptionController");
		const gameId = this.data.get("gameId");
		console.log(`Subscribing to GameUpdatesChannel for game ${gameId}`);
		this.subscription = consumer.subscriptions.create(
			{ channel: "GameUpdatesChannel", game_id: gameId },
			{
				received(data) {
					console.log(`Received data from GameUpdatesChannel ${gameId}`);
					console.log(data.message);
				},
			}
		);
	}

	disconnect() {
		if (this.subscription) {
			consumer.subscriptions.remove(this.subscription);
		}
	}
}
