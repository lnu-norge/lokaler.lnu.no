const plugin = require('tailwindcss/plugin')

module.exports = {
    // Purge unused TailwindCSS styles
    content: [
        './**/*.html.erb',
        './app/assets/images/**/*.svg',
        './app/helpers/**/*.rb',
        './app/javascript/**/*.js',
    ],
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
            boxShadow: {
                'inner-2xl-top': "inset 0 10px 30px -40px rgb(0 0 0 / 1)",
                'inner-2xl-left': "inset 10px 0 30px -40px rgb(0 0 0 / 1)"
            },
            screens: {
                'xs': '360px',
                '3xl': '1792px',
                '4xl': '2560px',
                'any-hover': {'raw': 'media (any-hover: hover)'}
            },
            cursor: {
                zoom: 'zoom-in'
            },
            spacing: {
                'safe-area-inset-bottom': 'env(safe-area-inset-bottom)',
                'safe-area-inset-top': 'env(safe-area-inset-top)',
                'safe-area-inset-left': 'env(safe-area-inset-left)',
                'safe-area-inset-right': 'env(safe-area-inset-right)',
                'desktop-menu-height': '3.5rem',
                'screen-below-desktop-menu': 'calc(100vh - 3.5rem)',
                md: '28rem',
                '1/3': '33.33333%',
                '2/5': '40%',
                '1/2': '50%',
                '3/5': '60%',
                '2/3': '66.666667%',
                '1/1': '100%',
                'screen-1/3': '33.33333vh',
                'screen-2/5': '40vh',
                'screen-1/2': '50vh',
                'screen-3/5': '60vh',
                'screen-2/3': '66.666667vh',
                '90vh': '90vh',
                fit: 'fit-content'
            },
            colors: {
                lnu: {
                    pink: '#C40066',
                    green: '#618467',
                    blue: '#175278',
                },
            },
            keyframes: {
                shake: {
                    '10%, 90%': { transform: 'translate3d(-1px, 0, 0)' },
                    '20%, 80%': { transform: 'translate3d(1px, 0, 0)' },
                    '30%, 50%, 70%': { transform: 'translate3d(-2px, 0, 0)' },
                    '40%, 60%': { transform: 'translate3d(2px, 0, 0)' },
                },
            },
            animation: {
                'shake-on-load': 'shake 0.3s ease-in-out',
                'pulse-on-load': 'pulse 0.5s ease-in-out',
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
        plugin(function({ addVariant }) {
            addVariant('view-as-table', 'body.view-as-table &');
            addVariant('view-as-map', 'body.view-as-map &');
        }),
    ],
}
