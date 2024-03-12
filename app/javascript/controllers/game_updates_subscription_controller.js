import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

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

					if (data.redirect) {
						console.log(`Redirecting to ${data.redirect}`);
						window.location.href = data.redirect;
					} else {
						// Clear Turbo Streams cache and force re-fetch
						Turbo.cache.clear();
						// Turbo.visit(window.location, { action: "replace" });
						Turbo.renderStreamMessage(data);
					}
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
