import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = [
		"checkbox",
		"card",
		"submitButton",
		"playerCheckbox",
		"playerCard",
		"playerSubmitButton",
	];
	connect() {
		this.multiSelectMode = false;
		this.multiSelectPlayerMode = false;
		console.log("connected");
	}

	toggleMultiSelect() {
		console.log("clicked");
		this.multiSelectMode = !this.multiSelectMode;
		console.log(this.multiSelectMode);

		this.checkboxTargets.forEach((checkbox) => {
			checkbox.style.display = this.multiSelectMode ? "inline" : "none";
		});

		this.cardTargets.forEach((card) => {
			card.disabled = this.multiSelectMode;
		});

		this.submitButtonTarget.style.display = this.multiSelectMode
			? "inline"
			: "none";
	}

	submitMultiSelect() {
		var selectedCards = [];

		this.checkboxTargets.forEach((checkbox) => {
			if (checkbox.checked) {
				selectedCards.push(checkbox.value);
			}
		});

		var formData = new FormData();

		selectedCards.forEach(function (cardId) {
			formData.append("card_ids[]", cardId);
		});

		fetch(this.submitButtonTarget.dataset.url, {
			method: "POST",
			body: formData,
			headers: {
				"X-Requested-With": "XMLHttpRequest",
				Accept: "text/vnd.turbo-stream.html",
			},
		})
			.then((response) => response.text())
			.then((html) => {
				Turbo.renderStreamMessage(html);
			});

		this.cardTargets.forEach((card) => {
			card.disabled = this.multiSelectMode;
		});
	}

	togglePlayerMultiSelect() {
		console.log("clicked");
		console.log(this.playerCheckboxTargets);
		this.multiSelectPlayerMode = !this.multiSelectPlayerMode;
		console.log(this.multiSelectPlayerMode);

		this.playerCheckboxTargets.forEach((playerCheckbox) => {
			console.log(playerCheckbox);
			playerCheckbox.style.display = this.multiSelectPlayerMode
				? "inline"
				: "none";
		});

		this.cardTargets.forEach((card) => {
			card.disabled = this.multiSelectPlayerMode;
		});

		this.playerSubmitButtonTarget.style.display = this.multiSelectPlayerMode
			? "inline"
			: "none";
	}

	submitCardsToMarket() {
		console.log("submitting cards to market");
		var selectedPlayerCards = [];
		this.playerCheckboxTargets.forEach((playerCheckbox) => {
			if (playerCheckbox.checked) {
				selectedPlayerCards.push(playerCheckbox.value);
			}
		});

		var formData = new FormData();

		selectedPlayerCards.forEach(function (playerCardId) {
			formData.append("player_card_ids[]", playerCardId);
		});

		fetch(this.playerSubmitButtonTarget.dataset.url, {
			method: "POST",
			body: formData,
			headers: {
				"X-Requested-With": "XMLHttpRequest",
				Accept: "text/vnd.turbo-stream.html",
			},
		})
			.then((response) => response.text())
			.then((html) => {
				Turbo.renderStreamMessage(html);
			});
	}
}
