// Minimal stand-in for Rails.ajax from the retired @rails/ujs package.
//
// ujs attached the CSRF token and the XMLHttpRequest marker to every request it
// sent; fetch does neither by default, so anything non-GET would be rejected by
// Rails' forgery protection without them.

export function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content;
}

export async function railsFetch(url, { method = 'GET', body, headers = {} } = {}) {
  const token = csrfToken();

  const response = await fetch(url, {
    method,
    body,
    credentials: 'same-origin',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      ...(token ? { 'X-CSRF-Token': token } : {}),
      ...headers,
    },
  });

  if (!response.ok) {
    throw new Error(`${method} ${url} responded ${response.status}`);
  }

  return response;
}
