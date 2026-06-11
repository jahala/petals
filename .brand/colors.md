# Brand Colors — plotplot

## Primary Palette

| Role | Hex | RGB | Usage |
|------|-----|-----|-------|
| Primary | #5F6F4E | rgb(95, 111, 78) | Primary brand color, key actions, selected states, product-wide emphasis. |
| Accent | #D97757 | rgb(217, 119, 87) | The bloom — CTAs, launch moments, attention marks, annotations. |
| Background | #F7F1E6 | rgb(247, 241, 230) | Main application and marketing background; warm paper base. |
| Text | #28241D | rgb(40, 36, 29) | Primary text, headings, high-emphasis interface copy. |
| Surface | #EFE7D8 | rgb(239, 231, 216) | Cards, panels, secondary sections, grouped content areas. |
| Border | #D8CCB8 | rgb(216, 204, 184) | Dividers, card borders, input borders, subtle structural lines. |

## Artifact-Tier Papers

Long-read polyglot surfaces use lighter paper for higher luminance during extended reading.

| Role | Hex | Usage |
|------|-----|-------|
| Artifact (primary) | #fbfaf8 | tend's main polyglot surface |
| Artifact (secondary) | #f5f3ee | tend's polyglot cards and panels |

## Semantic Roles

| Role | Hex | Usage |
|------|-----|-------|
| Healthy / Sound / verified | #4F7942 | Confirmed actions, healthy status, successful syncs, positive outcomes. |
| Caution / Warning / in-progress | #C9923C | Caution states, incomplete setup, drift warnings, review-needed signals. |
| Error / Broken / failed | #B85C3E | Destructive actions, validation errors, failed checks, high-risk alerts. |
| Info / neutral signal | #587383 | Informational notices, neutral signals, source notes, system guidance. |
| Draft / muted / missing | #8A8A86 | Not-yet-defined, placeholder, muted metadata. |

## Product Accents

Each product in the plotplot portfolio has its own accent. The primary palette is shared across all products.

| Product | Accent Hex | Role |
|---------|-----------|------|
| Root | #4B3A2A | Foundation |
| Soil | #735A43 | Memory |
| Seed | #A6A15F | Ideas |
| Tend | #D97757 | Roadmap |
| Stem | #4E6A4A | Strategy |
| Petal | #D39586 | Brand |
| Prune | #5B5A52 | Clarity |
| Graft | #5F8A7A | Integration |
| Cultivate | #5E7F8D | Signals |
| Weather | #7D8790 | Risk |
| Bloom | #D8745F | Launch |
| Harvest | #B89448 | Outcomes |
| Canopy | #3F5F46 | Leadership |

## Light / Dark Mode Variants

| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Primary | #5F6F4E | #A9B78D |
| Accent | #D97757 | #E0866B |
| Background | #F7F1E6 | #17140F |
| Text | #28241D | #EFE7D8 |
| Surface | #EFE7D8 | #231F18 |
| Border | #D8CCB8 | #453C30 |

## CSS Custom Properties

```css
:root {
  /* shared family palette */
  --pp-primary:    #5F6F4E;
  --pp-accent:     #D97757;   /* the bloom — was #C97863 */
  --pp-text:       #28241D;
  --pp-surface:    #EFE7D8;
  --pp-border:     #D8CCB8;
  --pp-bg:         #F7F1E6;   /* marketing paper */
  --pp-bg-artifact:#fbfaf8;   /* tend's lighter long-read paper */

  /* reconciled status (matches tend's glyph colors) */
  --pp-healthy: #4F7942;
  --pp-caution: #C9923C;
  --pp-error:   #B85C3E;
  --pp-info:    #587383;
  --pp-muted:   #8A8A86;

  /* product accents */
  --pp-tend: #D97757;  /* was #6F8157 */
  --pp-bloom: #D8745F; --pp-harvest: #B89448; --pp-canopy: #3F5F46;
  --pp-soil: #735A43;  --pp-root: #4B3A2A;    --pp-seed: #A6A15F;
  --pp-stem: #4E6A4A;  --pp-petal: #D39586;   --pp-prune: #5B5A52;
  --pp-graft: #5F8A7A; --pp-cultivate: #5E7F8D; --pp-weather: #7D8790;
}

[data-theme="dark"] {
  --pp-primary: #A9B78D;
  --pp-accent:  #E0866B;   /* clay lifts for dark contrast */
  --pp-text:    #EFE7D8;
  --pp-surface: #231F18;
  --pp-border:  #453C30;
  --pp-bg:      #17140F;   /* dark soil at night */
}
```
