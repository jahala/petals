# Brand Colors — Test Brand

## Primary Palette

| Role | Hex | RGB | CMYK | OKLCH |
|------|-----|-----|------|-------|
| Primary | #3DB8C4 | rgb(61, 184, 196) | cmyk(69, 6, 0, 23) | oklch(0.68, 0.12, 205) |
| Accent | #E8A838 | rgb(232, 168, 56) | cmyk(0, 28, 76, 9) | oklch(0.74, 0.14, 80) |
| Background | #FFFFFF | rgb(255, 255, 255) | cmyk(0, 0, 0, 0) | oklch(1.0, 0, 0) |
| Text | #1A1A1A | rgb(26, 26, 26) | cmyk(0, 0, 0, 90) | oklch(0.15, 0, 0) |

## Semantic Roles

| Role | Hex | Usage |
|------|-----|-------|
| Error | #D14343 | Destructive actions, error states |
| Success | #47B881 | Success confirmations, healthy states |
| Warning | #F0C040 | Warning alerts, caution states |
| Info | #3DB8C4 | Informational banners, tips |

## Light / Dark Mode Variants

| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Primary | #2F99A4 | #3DB8C4 |
| Background | #FFFFFF | #1A1A1A |
| Text | #1A1A1A | #F5F5F5 |
| Surface | #F8F8F8 | #2A2A2A |
| Border | #E6E6E6 | #3A3A3A |

## Usage Rules

- Primary color should occupy approximately 10-15% of the visible UI.
- Accent color is for calls-to-action and interactive highlights.
- Never use error color for non-error states.
- Maintain WCAG AA contrast ratio (4.5:1) for body text, AAA (7:1) where possible.

## Approved Combinations

| Background | Foreground | Contrast Ratio | Use For |
|-----------|-----------|----------------|---------|
| #FFFFFF | #2F99A4 | 3.2:1 | Headers, large text |
| #FFFFFF | #1A1A1A | 17.1:1 | Body text |
| #F8F8F8 | #2F99A4 | 2.9:1 | Cards, sections |

## Forbidden Combinations

- #2F99A4 text on #E8A838 background (too low contrast)
- #E8A838 text on #FFFFFF (below AA for body text)

## CSS Custom Properties

```css
:root {
  /* Primary palette */
  --color-primary: #3DB8C4;
  --color-accent: #E8A838;
  --color-background: #FFFFFF;
  --color-text: #1A1A1A;

  /* Semantic */
  --color-error: #D14343;
  --color-success: #47B881;
  --color-warning: #F0C040;
  --color-info: #3DB8C4;

  /* Dark mode */
  --color-primary-dark: #3DB8C4;
  --color-background-dark: #1A1A1A;
  --color-text-dark: #F5F5F5;
}
```
