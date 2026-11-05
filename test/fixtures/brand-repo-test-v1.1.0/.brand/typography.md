# Brand Typography — Test Brand

## Font Families

| Role | Family | Category |
|------|--------|----------|
| Heading | Inter | Sans-serif |
| Body | Inter | Sans-serif |
| Mono | JetBrains Mono | Monospace |

## Weight Scale

| Weight Name | Numeric | Usage |
|-------------|---------|-------|
| Light | 300 | Large headings, decorative |
| Regular | 400 | Body text, labels |
| Medium | 500 | Subheadings, emphasis |
| SemiBold | 600 | Section headings, buttons |
| Bold | 700 | Page titles, primary CTAs |

## Type Scale

| Level | Size | Line Height | Weight | Use |
|-------|------|------------|--------|-----|
| h1 | 36px | 1.2 | 700 | Page titles |
| h2 | 24px | 1.3 | 600 | Section titles |
| h3 | 18px | 1.4 | 600 | Subsection titles |
| body | 16px | 1.5 | 400 | Body text |
| small | 14px | 1.4 | 400 | Secondary text |
| caption | 12px | 1.4 | 400 | Captions, footnotes |

## @font-face Declarations

```css
/* Heading font — Inter */
@font-face {
  font-family: 'Inter';
  src: url('assets/inter-var.woff2') format('woff2');
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}
```

## Fallback Stacks

```css
--font-heading: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-body: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', monospace;
```

## Responsive Scale

| Breakpoint | Body Size | h1 Size | Scale Factor |
|------------|-----------|---------|-------------|
| < 768px | 16px | 28px | 1.200 |
| 768px+ | 16px | 32px | 1.250 |
| 1024px+ | 16px | 36px | 1.250 |

## Pairings

| Heading | Body | Use Case |
|---------|------|---------|
| Inter Bold | Inter Regular | Default for all content |
| Inter SemiBold | Inter Regular | Documentation pages |
