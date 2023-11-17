const defaultTheme = require('tailwindcss/defaultTheme')

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
        unsafe: ["'Noto Sans'", ...defaultTheme.fontFamily.sans],
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
