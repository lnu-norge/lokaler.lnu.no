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
    zIndex: {
      '-10' : -10,
      '0': 0,
      '10': 10,
      '20': 20,
      '30': 30,
      '40': 40,
      '50': 50,
      '25': 25,
      '50': 50,
      '75': 75,
      '100': 100,
      'auto': 'auto',
    },
    extend: {
      maxHeight: {
        '90vh': '90vh'
      },
      spacing: {
        '2/3': '66.666667%',
      },
      colors: {
        lnu: {
          pink: '#C40066',
          green: '#618467',
          blue: '#175278',
        },
      },
    },
  },
  variants: {
    extend: {
      transitionProperty: ['hover', 'focus'],
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
