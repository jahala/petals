# Typography — plotplot

## Font Families

| Role | Font Family | Weight | Style |
|------|------------|--------|-------|
| Headings | Sora | 600, 700 | normal |
| Body | Source Sans 3 | 400, 500, 600 | normal |
| Interface | Source Sans 3 | 400, 500, 600 | normal |
| Code | JetBrains Mono | 400, 500 | normal |

## Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | 400 | Body, interface |
| Medium | 500 | Labels, small headings |
| Semibold | 600 | Subheadings |
| Bold | 700 | Headings |

## Type Scale

| Level | Size | Line Height | Weight | Usage |
|-------|------|------------|--------|-------|
| h1 | 44px | 1.2 | Bold | Page titles |
| h2 | 32px | 1.25 | Bold | Section headings |
| h3 | 24px | 1.3 | Semibold | Subsection headings |
| h4 | 18px | 1.35 | Semibold | Card titles |
| body | 16px | 1.5 | Regular | Body text |
| small | 14px | 1.4 | Regular | Captions, labels |
| code | 13px | 1.5 | Regular | Code blocks |

## Spacing Scale

Multiples of 4px:

| Token | Value | Usage |
|-------|-------|-------|
| 4xs | 4px | Tight icon padding |
| 3xs | 8px | Inline spacing |
| 2xs | 12px | Component inner |
| xs | 16px | Compact section |
| sm | 24px | Standard section |
| md | 32px | Major section |
| lg | 48px | Page sections |
| xl | 64px | Hero spacing |
| 2xl | 96px | Layout breaks |

## Font Sources

- Sora: Google Fonts — used for headings because it has a distinctive, literate geometric voice without feeling playful.
- Source Sans 3: Google Fonts — used for body and interface because it is readable, neutral, warm, and precise.
- JetBrains Mono: Google Fonts — used for code because it is compact, legible, and familiar in developer workflows.

## Google Fonts Import

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&family=Sora:wght@600;700&family=Source+Sans+3:wght@400;500;600;700&display=swap" rel="stylesheet">
```

```css
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&family=Sora:wght@600;700&family=Source+Sans+3:wght@400;500;600;700&display=swap');

:root {
  --font-heading: 'Sora', sans-serif;
  --font-body: 'Source Sans 3', sans-serif;
  --font-interface: 'Source Sans 3', sans-serif;
  --font-code: 'JetBrains Mono', monospace;
}
```
