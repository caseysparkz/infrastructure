const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

// tailwind.config.js
module.exports = {
    content: ['./layouts/**/*.html', './content/**/*.md'],
    darkMode: 'class',
    theme: {
        colors: {
            transparent: 'transparent',
            current: 'currentColor',
            black: colors.black,
            white: colors.white,
            gray: colors.gray,
            emerald: colors.emerald,
            indigo: colors.indigo,
            yellow: colors.yellow,
            },
        extend: {
            colors: {
                transparent: 'transparent',
                current: 'currentColor',
                'primary': {
                    DEFAULT: '#6366F1',
                    50: '#FFFFFF',
                    100: '#F9F9FE',
                    200: '#D3D4FB',
                    300: '#AEAFF8',
                    400: '#888BF4',
                    500: '#6366F1',
                    600: '#3034EC',
                    700: '#1317D1',
                    800: '#0E119E',
                    900: '#0A0C6A'
                    },
                'secondary': {
                    DEFAULT: '#EC4899',
                    50: '#FDEEF6',
                    100: '#FBDCEB',
                    200: '#F8B7D7',
                    300: '#F492C2',
                    400: '#F06DAE',
                    500: '#EC4899',
                    600: '#E4187D',
                    700: '#B11261',
                    800: '#7F0D45',
                    900: '#4C0829'
                    },
                'neutral': {
                    DEFAULT: '#6B7280',
                    50: '#CDD0D5',
                    100: '#C2C5CC',
                    200: '#ACB0BA',
                    300: '#969BA7',
                    400: '#7F8694',
                    500: '#6B7280',
                    600: '#515761',
                    700: '#383C43',
                    800: '#1E2024',
                    900: '#050506'
                    },
                'pale-sky': {
                    DEFAULT: '#6B7280',
                    50: '#FFFFFF',
                    100: '#FFFFFF',
                    200: '#FFFFFF',
                    300: '#FAFAFB',
                    400: '#E3E5E8',
                    500: '#CDD0D5',
                    600: '#B7BBC3',
                    700: '#A1A6B0',
                    800: '#8B919E',
                    900: '#747C8B',
                    950: '#6B7280'
                    },
                // To change these, use https://www.tailwindshades.com/ with https://tailwindcss.com/docs/customizing-colors or create your own custom colors.
                },
            lineHeight: {
                'extra-loose': '2.5',
                '12': '3rem',
                },
            typography: (theme) => ({
                DEFAULT: {
                    css: {
                        '--tw-prose-body': theme('colors.zinc[800]'),
                        '--tw-prose-headings': theme('colors.zinc[900]'),
                        '--tw-prose-lead': theme('colors.zinc[700]'),
                        '--tw-prose-links': theme('colors.zinc[900]'),
                        '--tw-prose-bold': theme('colors.zinc[900]'),
                        '--tw-prose-counters': theme('colors.zinc[600]'),
                        '--tw-prose-bullets': theme('colors.zinc[400]'),
                        '--tw-prose-hr': theme('colors.zinc[300]'),
                        '--tw-prose-quotes': theme('colors.zinc[900]'),
                        '--tw-prose-quote-borders': theme('colors.zinc[300]'),
                        '--tw-prose-captions': theme('colors.zinc[700]'),
                        '--tw-prose-code': theme('colors.indigo[500]'),
                        '--tw-prose-pre-code': theme('colors.indigo[300]'),
                        '--tw-prose-pre-bg': theme('colors.gray[900]'),
                        '--tw-prose-th-borders': theme('colors.zinc[300]'),
                        '--tw-prose-td-borders': theme('colors.zinc[200]'),
                        '--tw-prose-invert-body': theme('colors.zinc[200]'),
                        '--tw-prose-invert-headings': theme('colors.white'),
                        '--tw-prose-invert-lead': theme('colors.zinc[300]'),
                        '--tw-prose-invert-links': theme('colors.indigo[400]'),
                        '--tw-prose-invert-bold': theme('colors.white'),
                        '--tw-prose-invert-counters': theme('colors.zinc[400]'),
                        '--tw-prose-invert-bullets': theme('colors.zinc[200]'),
                        '--tw-prose-invert-hr': theme('colors.zinc[500]'),
                        '--tw-prose-invert-quotes': theme('colors.zinc[100]'),
                        '--tw-prose-invert-quote-borders': theme('colors.zinc[700]'),
                        '--tw-prose-invert-captions': theme('colors.zinc[400]'),
                        '--tw-prose-invert-code': theme('colors.indigo[400]'),
                        '--tw-prose-invert-pre-code': theme('colors.indigo[300]'),
                        '--tw-prose-invert-pre-bg': theme('colors.gray[900]'),
                        '--tw-prose-invert-th-borders': theme('colors.zinc[100]'),
                        '--tw-prose-invert-td-borders': theme('colors.zinc[500]'),
                        },
                    },
                }),
            },
        },
    variants: {typography: ["dark"]},
    plugins: [require("@tailwindcss/typography")],
    };
