# Brand Colors — plotplot

## Primary Palette

| Role | Hex | RGB | Usage |
|------|-----|-----|-------|
| Primary | #3F7A33 | rgb(63, 122, 51) | Primary brand green — buttons, key actions, links, selected states, product-wide emphasis. Vital leaf green (4.76:1 on paper) — alive, not archival; evolved from the gray-olive #4C5E3C. |
| Primary (deep) | #356428 | rgb(53, 100, 40) | Hover / pressed states of primary; one step deeper into the foliage. |
| Accent | #C04B3C | rgb(192, 75, 60) | The bloom — vivid blossom clay (4.47:1 on paper — labels and display, not body text). CTAs, launch moments, attention marks, annotations, kicker labels, display numerals. Evolved from the dried-clay #B96A4F for vitality. |
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
| Healthy / Sound / verified | #46913C | Confirmed actions, healthy status, successful syncs, positive outcomes. Brightened in step with the vital-leaf primary. |
| Caution / Warning / in-progress | #C9923C | Caution states, incomplete setup, drift warnings, review-needed signals. |
| Error / Broken / failed | #B85C3E | Destructive actions, validation errors, failed checks, high-risk alerts. |
| Info / neutral signal | #587383 | Informational notices, neutral signals, source notes, system guidance. |
| Draft / muted / missing | #8A8A86 | Not-yet-defined, placeholder, disabled states. On paper surfaces it is decorative-only (3.18:1) — readable copy uses Text (soft) instead. On terminal soil it reads fine (5.09:1). |

## Product Accents

Each product in the plotplot portfolio has its own accent. The primary palette is shared across all products.

| Product | Accent Hex | Role |
|---------|-----------|------|
| root | #4B3A2A | Foundation |
| soil | #735A43 | Memory |
| seed | #A6A15F | Ideas |
| tend | #D97757 | Roadmap |
| stem | #4E6A4A | Strategy |
| petals | #E8917F | Brand |
| prune | #5B5A52 | Clarity |
| graft | #5F8A7A | Integration |
| cultivate | #5E7F8D | Signals |
| weather | #7D8790 | Risk |
| bloom | #D8745F | Launch |
| harvest | #B89448 | Outcomes |
| canopy | #3F5F46 | Leadership |

## Contrast Pairings

Color is only on-brand when it is legible. Three pair classes:

- **Reading copy** (body text, captions, notes): ratio ≥ **4.5:1**
- **Labels & display** (short uppercase labels, severity tags, kickers, display-size type ≥ 24px): ratio ≥ **3.0:1**
- **Decorative** (dividers, washes, marks — never words): exempt

Canonical pairs, measured (WCAG 2.x relative luminance):

| Foreground on background | Ratio | Class |
|---|---|---|
| Text #20241B on Paper #F8F5EC | 14.49 | reading |
| Text (soft) #5A6150 on Paper #F8F5EC | 5.91 | reading |
| Text (soft) #5A6150 on Band / Surface | 5.48 / 5.49 | reading |
| Primary #3F7A33 on Paper #F8F5EC | 4.76 | reading (links) |
| Accent #C04B3C on Paper #F8F5EC | 4.47 | labels & display only |
| Info #587383 on Surface #F0EDE1 | 4.27 | labels |
| Error #B85C3E on Paper / Surface | 4.15 / 3.86 | labels |
| Healthy #46913C on Surface #F0EDE1 | 3.33 | labels |
| Muted #8A8A86 on Paper #F8F5EC | 3.18 | decorative / disabled only |
| Paper #F8F5EC on Primary #3F7A33 | 4.76 | reading |
| Surface #F0EDE1 on Terminal #161A12 | 15.04 | reading |
| Terminal green #8FCB63 on Terminal | 9.15 | reading |
| Terminal info #7E9DAD on Terminal | 6.14 | reading |
| Muted #8A8A86 on Terminal | 5.09 | reading |
| Error / Caution / Accent on Terminal | 3.90 / 6.43 / 3.62 | labels |

Pairs that fail their class are off-brand even though both colors are in the
palette. Known traps: Caution #C9923C on light surfaces (2.34) and Petal
#E8917F on Primary (2.17) — decorative only, never words.

## Data Visualization

Charts draw from the family — never library defaults.

- **Categorical series**, in order: 1 Primary #3F7A33 · 2 Accent #C04B3C ·
  3 Info #587383 · 4 Caution #C9923C · 5 Petal #E8917F · 6 Graft #5F8A7A
- **Sequential ramp**: #356428 → #3F7A33 → #8FCB63 (leaf family)
- **Diverging**: Primary #3F7A33 ↔ Accent #C04B3C through Border #D6D2C2
- Gridlines: Border #D6D2C2 · axis labels: Text (soft) #5A6150

## Light / Dark Mode Variants

| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Primary | #3F7A33 | #A9B78D |
| Accent | #C04B3C | #E0866B |
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
| Terminal green (in-pane) | #8FCB63 | Vivid-leaf command / OK lines — legible and alive on the deep terminal soil. |
| Terminal info (in-pane) | #7E9DAD | Brightened informational lines inside the terminal (6.6:1). |

## CSS Custom Properties

```css
:root {
  /* shared family palette */
  --pp-primary:    #3F7A33;   /* vital leaf green — evolved from #4C5E3C */
  --pp-primary-deep: #356428; /* hover / pressed — deep leaf */
  --pp-accent:     #C04B3C;   /* the bloom, vivid — evolved from #B96A4F */
  --pp-text:       #20241B;   /* warm near-black — deepened from #28241D */
  --pp-text-soft:  #5A6150;   /* secondary prose — warm, AA on cream */
  --pp-surface:    #F0EDE1;
  --pp-border:     #D6D2C2;
  --pp-bg:         #F8F5EC;   /* marketing paper */
  --pp-bg-band:    #EFEDE2;   /* alternating section band */
  --pp-bg-artifact:#fbfaf8;   /* tend's lighter long-read paper */

  /* reconciled status (matches tend's glyph colors) */
  --pp-healthy: #46913C;
  --pp-caution: #C9923C;
  --pp-error:   #B85C3E;
  --pp-info:    #587383;
  --pp-muted:   #8A8A86;

  /* product accents */
  --pp-tend: #B96A4F;  /* was #6F8157 */
  --pp-bloom: #D8745F; --pp-harvest: #B89448; --pp-canopy: #3F5F46;
  --pp-soil: #735A43;  --pp-root: #4B3A2A;    --pp-seed: #A6A15F;
  --pp-stem: #4E6A4A;  --pp-petal: #E8917F;   --pp-prune: #5B5A52;
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
