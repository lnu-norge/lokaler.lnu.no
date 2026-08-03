module.exports = {
  plugins: {
    'postcss-extend-rule': {}, // Allows scss style extending with @extend
    '@tailwindcss/postcss': {}, // Tailwind v4: also handles @import, nesting and vendor prefixing
    'postcss-url': {
      url: 'inline', // Converts all css images to base64
    },
  },
}
