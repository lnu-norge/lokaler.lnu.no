module.exports = {
  plugins: {
    'postcss-import': {}, // Allows @import on top of css files
    'tailwindcss/nesting': {}, // Allows scss style nesting, e.g. h2 { xxx .fancy { yyy }  } will compile to h2 { xxx }; h2.fancy { yyy };
    'postcss-extend-rule': {}, // Allows scss style extending with @extend
    tailwindcss: {}, // Allows tailwind
    'postcss-url': {
      url: 'inline', // Converts all css images to base64
    },
    autoprefixer: {}, // Adds vendor prefixes to stuff
  },
}
