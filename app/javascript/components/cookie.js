function baseFetch(url, method, body = null) {
  fetch(url, {
    method,
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content'),
      'X-Requested-With': 'XMLHttpRequest',
      'Content-Type': 'application/json'
    },
    body
  })
}

export function cookieSetter(name, value) {
  baseFetch('/cookies', 'POST', JSON.stringify({ name, value }))
}

export function cookieRemover(name) {
  baseFetch(`/cookies/${name}`, 'DELETE')
}
