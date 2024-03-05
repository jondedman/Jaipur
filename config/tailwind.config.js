const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
	purge: {
		content: [
			"./public/*.html",
			"./app/helpers/**/*.rb",
			"./app/javascript/**/*.js",
			"./app/views/**/*.{erb,haml,html,slim}",
		],
		theme: {
			extend: {
				fontFamily: {
					sans: ["Inter var", ...defaultTheme.fontFamily.sans],
				},
				boxShadow: {
					obvious: "6px 4px 10px 10px rgba(0, 0, 0, 0.4)",
				},
				screens: {
					xs: "375px",

					portrait: { raw: "(orientation: portrait)" },
				},
			},
		},
		plugins: [
			require("@tailwindcss/forms"),
			require("@tailwindcss/aspect-ratio"),
			require("@tailwindcss/typography"),
			require("@tailwindcss/container-queries"),
		],
	},
};
