# Accessibility fixtures

`page.html` breaks each source-level accessibility rule once, next to an
accepted form of the same element, so each finding's line is known. `clean.html`
removes the outline but restores focus with `:focus-visible`, and should pass.
tests/access.spec.sh judges both.
