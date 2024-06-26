const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

function withOpacity(varName) {
  return ({ opacityValue }) => {
    if (opacityValue != undefined) {
      return `rgba(var(${varName}), ${opacityValue})`
    }
    return `rgba(var(${varName}))`
  }
}

module.exports = {
  content: [
    './app/assets/stylesheets/safe-list.css',
    './app/assets/stylesheets/pagy.css',
    './app/components/**/*.{rb,erb,html,slim}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,html,slim}',
    './config/initializers/simple_form.rb',
    "./lib/filterable_lib/**/*.{rb,erb,html,slim}",
    './public/*.html',

  ],
  theme: {
    extend: {
      fontFamily: {
        unsafe: ["'Noto Sans'", ...defaultTheme.fontFamily.sans],
        anemone: ["Avenir", ...defaultTheme.fontFamily.sans],
        kenjosset: ["Scandia", ...defaultTheme.fontFamily.sans],
      },
      colors:{
        primary: withOpacity('--color-primary'),
        secondary: withOpacity('--color-secondary'),
        light: withOpacity('--color-light'),
        content: withOpacity('--color-content'),
        contrast: withOpacity('--color-contrast'),
        midgray: withOpacity('--color-midgray'),
        contour: withOpacity('--color-contour'),
        'form-input': withOpacity('--color-form-input'),
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
  ]
}
