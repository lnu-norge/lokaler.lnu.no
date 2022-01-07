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
      '1': 1,
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9,
      '10': 10,
      '20': 20,
      '30': 30,
      '40': 40,
      '25': 25,
      '50': 50,
      '75': 75,
      '100': 100,
      'auto': 'auto',
    },
    extend: {
      cursor: {
        zoom: 'zoom-in'
      },
      maxHeight: {
        '90vh': '90vh',
      },
      spacing: {
        md: '28rem',
        '1/3': '33.33333%',
        '2/5': '40%',
        '1/2': '50%',
        '3/5': '60%',
        '2/3': '66.666667%',
        'screen-1/3': '33.33333vh',
        'screen-2/5': '40vh',
        'screen-1/2': '50vh',
        'screen-3/5': '60vh',
        'screen-2/3': '66.666667vh',
        fit: 'fit-content'
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
