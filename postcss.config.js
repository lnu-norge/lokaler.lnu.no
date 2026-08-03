module.exports = {
  plugins: {
    // Tailwind v4 also handles @import, nesting and vendor prefixing, so
    // postcss-import, tailwindcss/nesting and autoprefixer are no longer needed.
    // postcss-extend-rule is gone too: @extend depended on postcss-import having
    // already inlined every stylesheet, and its targets are all @utility blocks
    // now, so they are pulled in with @apply instead.
    '@tailwindcss/postcss': {},
    'postcss-url': {
      url: 'inline', // Converts all css images to base64
    },
  },
}
