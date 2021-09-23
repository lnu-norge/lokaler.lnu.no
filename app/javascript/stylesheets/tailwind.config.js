module.exports = {
  // Purge unused TailwindCSS styles
  purge: {
    enabled: ["production"].includes(process.env.NODE_ENV),
    content: [
      './**/*.html.erb',
      './app/assets/images/**/*.svg',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js',
    ],
  },
  darkMode: 'media', // or 'media' or 'class'
  theme: {
    extend: {
      spacing: {
        '2/3': '66.666667%',
      }
    },
  },
  variants: {
  },
  plugins: [],
}