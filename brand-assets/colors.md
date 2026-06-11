# Brand Colors — Plotplot

## Primary Palette

| Role | Hex | RGB | Usage |
|------|-----|-----|-------|
| Primary | #4A6741 | rgb(74, 103, 65) | Primary brand color, key actions, selected states, product-wide emphasis. |
| Accent | #E0704C | rgb(224, 112, 76) | Highlights, CTAs, launch moments, attention marks, annotations. |
| Background | #F7F1E6 | rgb(247, 241, 230) | Main application and marketing background; warm paper base. |
| Text | #28241D | rgb(40, 36, 29) | Primary text, headings, high-emphasis interface copy. |
| Surface | #EFE7D8 | rgb(239, 231, 216) | Cards, panels, secondary sections, grouped content areas. |
| Border | #C4B8A2 | rgb(196, 184, 162) | Dividers, card borders, input borders, subtle structural lines. |

## Semantic Roles

| Role | Hex | Usage |
|------|-----|-------|
| Error | #B8453A | Destructive actions, validation errors, failed checks, high-risk alerts. |
| Success | #4A7A42 | Confirmed actions, healthy status, successful syncs, positive outcomes. |
| Warning | #C48A2E | Caution states, incomplete setup, drift warnings, review-needed signals. |
| Info | #587383 | Informational notices, neutral signals, source notes, system guidance. |

## Product Accents

Each product in the Plotplot portfolio has its own accent. The primary palette
is shared across all products.

| Product | Accent Hex | Role |
|---------|-----------|------|
| Root | #4B3A2A | Foundation |
| Soil | #735A43 | Memory |
| Seed | #9B9652 | Ideas |
| Tend | #5A7A4A | Roadmap |
| Stem | #3D5C38 | Strategy |
| Petal | #D4784C | Brand |
| Prune | #5B5A52 | Clarity |
| Graft | #4E7A68 | Integration |
| Cultivate | #4E7282 | Signals |
| Weather | #7D8790 | Risk |
| Bloom | #E05A3C | Launch |
| Harvest | #B89448 | Outcomes |
| Canopy | #36583E | Leadership |

## Light / Dark Mode Variants

| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Primary | #4A6741 | #8CB580 |
| Background | #F7F1E6 | #17140F |
| Text | #28241D | #EFE7D8 |
| Surface | #EFE7D8 | #231F18 |
| Border | #C4B8A2 | #3D362E |

## CSS Custom Properties

```css
:root {
  --color-primary: #4A6741;
  --color-accent: #E0704C;
  --color-background: #F7F1E6;
  --color-text: #28241D;
  --color-surface: #EFE7D8;
  --color-border: #C4B8A2;
  --color-error: #B8453A;
  --color-success: #4A7A42;
  --color-warning: #C48A2E;
  --color-info: #587383;
  --color-product-root: #4B3A2A;
  --color-product-soil: #735A43;
  --color-product-seed: #9B9652;
  --color-product-tend: #5A7A4A;
  --color-product-stem: #3D5C38;
  --color-product-petal: #D4784C;
  --color-product-prune: #5B5A52;
  --color-product-graft: #4E7A68;
  --color-product-cultivate: #4E7282;
  --color-product-weather: #7D8790;
  --color-product-bloom: #E05A3C;
  --color-product-harvest: #B89448;
  --color-product-canopy: #36583E;
}

[data-theme="dark"] {
  --color-primary: #8CB580;
  --color-accent: #D4784C;
  --color-background: #17140F;
  --color-text: #EFE7D8;
  --color-surface: #231F18;
  --color-border: #3D362E;
  --color-error: #C47165;
  --color-success: #8CB580;
  --color-warning: #D4A43E;
  --color-info: #8EABB8;
}
```
