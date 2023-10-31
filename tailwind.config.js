const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './app/components/**/*.{rb,erb,html,slim}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,html,slim}',
    './public/*.html',
    './config/initializers/simple_form.rb',

  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors:{
        primary: "#8B80F9",
        secondary: "#61C9A8",
        light: colors.sky[50],
        content: colors.gray[400]
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
  ]
}
