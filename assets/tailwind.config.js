module.exports = {
  content: [
    "./**/*.js",
    "../lib/personal.ex",
  ],
  theme: {
    extend: {
      colors: {
        'blurple': '#5C5CFF',
        'bludacris': '#2CB4FF',
        'cutecumber': '#20E0D6',
        'pink-power-ranger': '#FF5290',
        'smurf-blood': '#0B1A38',
        'nor-easter': '#F5F7FA',
        'grapefruit': '#FF8389'
      },
      boxShadow: {
        'DEFAULT': '10px 10px 0 #20E0D6',
      }
    },
  },

  plugins: [
    require("@tailwindcss/typography"),
  ]
};
