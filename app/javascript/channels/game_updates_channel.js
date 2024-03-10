// import consumer from "channels/consumer";

// consumer.subscriptions.create("GameUpdatesChannel", {
// 	connected() {
// 		// Called when the subscription is ready for use on the server
// 	},

// 	disconnected() {
// 		// Called when the subscription has been terminated by the server
// 	},

// 	received(data) {
// 		// Called when there's incoming data on the websocket for this channel
// 		console.log(data.message); // This will log "Hello, world!" to the console
// 	},
// });

// export default function subscribeToGameChannel(gameId) {
// 	consumer.subscriptions.create(
// 		{ channel: "GameUpdates", id: gameId },
// 		{
// 			received(data) {
// 				console.log("Received data from GameUpdatesChannel");
// 				console.log(data);
// 			},
// 		}
// 	);
// }
