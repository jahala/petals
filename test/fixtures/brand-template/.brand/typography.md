# Brand Typography: larch

<!--
  Template: typography.md
  Font weights and styles must be stated in the source. Do not guess weights
  from a family name.
-->

## Font Families

| Role | Font Family | Weight | Style |
|------|------------|--------|-------|
| Heading | Fraunces | 400, 600 | normal |
| Body | Inter | 400..700 | normal |
| Code | Space Mono | 400, 700 | normal |

## Weight Scale

| Weight Name | Numeric | Usage |
|-------------|---------|-------|
| Light | not specified | not used |
| Regular | 400 | Body, headings |
| Medium | 500 | Labels |
| SemiBold | 600 | Buttons, heading emphasis |
| Bold | 700 | Strong emphasis in body |

## Type Scale

| Level | Size | Line Height | Weight | Use |
|-------|------|------------|--------|-----|
| h1 | 3rem | 1.1 | 400 | Page titles |
| h2 | 2rem | 1.2 | 400 | Section headings |
| h3 | 1.4rem | 1.3 | 600 | Subsections |
| body | 1rem | 1.6 | 400 | Body text |
| small | 0.875rem | 1.5 | 400 | Captions |
| caption | 0.75rem | 1.4 | 500 | Labels |

## Font Loading

```html
<link rel="stylesheet" href="/fonts/larch.css">
```

## @font-face Declarations

```css
/* Heading font: Fraunces */
@font-face {
  font-family: 'Fraunces';
  src: url('/fonts/fraunces.woff2') format('woff2');
  font-weight: 400 600;
  font-style: normal;
  font-display: swap;
}

/* Body font: Inter */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter.woff2') format('woff2');
  font-weight: 400 700;
  font-style: normal;
  font-display: swap;
}
```

## Fallback Stacks

```css
--font-heading: 'Fraunces', Georgia, serif;
--font-body: 'Inter', system-ui, sans-serif;
--font-code: 'Space Mono', ui-monospace, monospace;
```

## Responsive Scale

| Breakpoint | Body Size | h1 Size | Scale Factor |
|------------|-----------|---------|-------------|
| < 640px | 0.9375rem | 2.25rem | 0.75 |
| 640px+ | 1rem | 2.6rem | 0.87 |
| 1024px+ | 1rem | 3rem | 1 |

## Pairings

| Heading | Body | Use Case |
|---------|------|---------|
| Fraunces | Inter | Everything |
