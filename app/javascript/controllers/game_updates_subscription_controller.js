import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
	connect() {
		console.log("Connected to GameUpdatesSubscriptionController");
		const gameId = this.data.get("gameId");
		console.log(`Subscribing to GameUpdatesChannel for game ${gameId}`);
		this.subscription = consumer.subscriptions.create(
			{ channel: "GameUpdatesChannel", game_id: gameId },
			// { channel: "GameUpdatesChannel", game: `game_updates ${gameId}` },
			{
				received(data) {
					console.log(`Received data from GameUpdatesChannel ${gameId}`);
					if (data.message) {
						const gameUpdatesFrame = document.getElementById("game_updates");
						if (gameUpdatesFrame) {
							gameUpdatesFrame.innerHTML = `<p class="py-2 px-3 bg-black bg-opacity-70 mb-5 text-white text-2xl font-m font-bold mt-2 rounded-lg inline-block animate-pulse" id="game_notice">${data.message}</p>`;
						}
					} else if (data.redirect) {
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
