import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

// Connects to data-controller="game-updates-subscription"
export default class extends Controller {
	static values = { gameId: Number, playerId: Number };
	connect() {
		console.log("Player ID: ", this.playerIdValue);
		this.subscription = consumer.subscriptions.create(
			{ channel: "GameUpdatesChannel", game_id: this.gameIdValue },
			{
				received: this.received.bind(this),
			}
		);
		console.log("Connected to GameUpdatesChannel");
	}

	received(data) {
		console.log("Received data from GameUpdatesChannel");
		console.log(data);
	}

	disconnect() {
		if (this.subscription) {
			consumer.subscriptions.remove(this.subscription);
		}
	}
}
