# Brand Colors — plotplot

## Primary Palette

| Role | Hex | RGB | Usage |
|------|-----|-----|-------|
| Primary | #4C5E3C | rgb(76, 94, 60) | Primary brand green — buttons, key actions, links, selected states, product-wide emphasis. Deepened from #5F6F4E for confident contrast (6.28:1 on cream). |
| Accent | #B96A4F | rgb(185, 106, 79) | The bloom — CTAs, launch moments, attention marks, annotations, kicker labels, display numerals. |
| Background | #F8F5EC | rgb(248, 245, 236) | Main application and marketing background; warm paper base. |
| Background (band) | #EFEDE2 | rgb(239, 237, 226) | Alternating section band — a half-step deeper than the paper base, for vertical rhythm. |
| Text | #20241B | rgb(32, 36, 27) | Primary text, headings, high-emphasis copy. Deepened warm near-black (14.91:1 on cream). |
| Text (soft) | #5A6150 | rgb(90, 97, 80) | Secondary prose, muted captions, annotation copy. Warm — AA on cream (6.49:1). |
| Surface | #F0EDE1 | rgb(240, 237, 225) | Cards, panels, secondary sections, grouped content areas. |
| Border | #D6D2C2 | rgb(214, 210, 194) | Dividers, card borders, input borders, subtle structural lines. |

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
| Primary | #4C5E3C | #A9B78D |
| Accent | #B96A4F | #E0866B |
| Background | #F8F5EC | #17140F |
| Text | #20241B | #F0EDE1 |
| Surface | #F0EDE1 | #20251B |
| Border | #D6D2C2 | #3C4433 |

## Terminal Surfaces

Embedded terminal panes (the landing-page demos) run a deepened dark soil so the warm-paper page reads above them and the in-pane accent lines pop.

| Role | Hex | Usage |
|------|-----|-------|
| Terminal background | #161A12 | Deepened soil-black behind terminal text (15.3:1 for surface text). |
| Terminal surface | #20251B | Titlebar / chrome inside the terminal pane. |
| Terminal border | #3C4433 | Terminal pane and titlebar dividers. |
| Terminal green (in-pane) | #86B36E | Brightened command / OK lines — legible on the deep terminal soil (7.8:1). |
| Terminal info (in-pane) | #7E9DAD | Brightened informational lines inside the terminal (6.6:1). |

## CSS Custom Properties

```css
:root {
  /* shared family palette */
  --pp-primary:    #4C5E3C;   /* botanical green — deepened from #5F6F4E */
  --pp-accent:     #B96A4F;   /* the bloom — was #C97863 */
  --pp-text:       #20241B;   /* warm near-black — deepened from #28241D */
  --pp-text-soft:  #5A6150;   /* secondary prose — warm, AA on cream */
  --pp-surface:    #F0EDE1;
  --pp-border:     #D6D2C2;
  --pp-bg:         #F8F5EC;   /* marketing paper */
  --pp-bg-band:    #EFEDE2;   /* alternating section band */
  --pp-bg-artifact:#fbfaf8;   /* tend's lighter long-read paper */

  /* reconciled status (matches tend's glyph colors) */
  --pp-healthy: #4F7942;
  --pp-caution: #C9923C;
  --pp-error:   #B85C3E;
  --pp-info:    #587383;
  --pp-muted:   #8A8A86;

  /* product accents */
  --pp-tend: #B96A4F;  /* was #6F8157 */
  --pp-bloom: #D8745F; --pp-harvest: #B89448; --pp-canopy: #3F5F46;
  --pp-soil: #735A43;  --pp-root: #4B3A2A;    --pp-seed: #A6A15F;
  --pp-stem: #4E6A4A;  --pp-petal: #D39586;   --pp-prune: #5B5A52;
  --pp-graft: #5F8A7A; --pp-cultivate: #5E7F8D; --pp-weather: #7D8790;
}

[data-theme="dark"] {
  --pp-primary: #A9B78D;
  --pp-accent:  #E0866B;   /* clay lifts for dark contrast */
  --pp-text:    #F0EDE1;
  --pp-surface: #20251B;
  --pp-border:  #3C4433;
  --pp-bg:      #17140F;   /* dark soil at night */
}
```
