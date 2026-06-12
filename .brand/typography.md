# Typography — plotplot

## Font Families

| Role | Font Family | Weight | Style |
|------|------------|--------|-------|
| Headings | Fraunces | 500, 560, 600, 620 | normal |
| Body | Source Sans 3 | 400, 500, 600, 700 | normal |
| Interface | Source Sans 3 | 400, 500, 600 | normal |
| Code | JetBrains Mono | 400, 500 | normal |

## Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | 400 | Body, interface |
| Medium | 500 | Labels, small headings, h3/h4 |
| Display | 560 | h2 |
| Semibold | 600 | Subheadings, emphasis |
| Display Bold | 620 | h1 |
| Bold | 700 | Strong body emphasis, stat numerals |

Fraunces is a variable font with optical sizing (`opsz`) and a soft axis (`SOFT`). Headings set `font-optical-sizing: auto`; display headings carry a touch of `SOFT` for warmth.

## Type Scale

Base: `html { font-size: 18px }`. Sizes below are in `rem` (relative to 18px) for fluid scaling; the clamp on h1 keeps the hero balanced across viewports.

| Level | Size | Line Height | Weight | Usage |
|-------|------|------------|--------|-------|
| h1 | clamp(3.4rem, 6vw, 4.6rem) | 1.04 | 620 | Page / hero titles |
| h2 | 2.4rem | 1.12 | 560 | Section headings |
| h3 | 1.6rem | 1.2 | 560 | Subsection headings |
| h4 | 1.25rem | 1.3 | 560 | Card titles |
| lead | 1.3rem | 1.5 | 400 | Hero deck, section ledes |
| body | 1.0625rem | 1.65 | 400 | Body text |
| small | 0.9375rem | 1.5 | 400 | Captions, labels |
| stat | 3.75rem | 1.0 | 700 | Display numerals |
| code | 0.95rem | 1.6 | 400 | Code / terminal text |

## Spacing

The spacing scale moved to `layout.md`, where it lives with the containers,
breakpoints, and density rules it belongs to. Typography owns type only.

## Font Sources

- Fraunces: Google Fonts — used for headings and display because it is a warm, characterful serif with optical sizing and a soft axis; literate and botanical (fits "petals") without feeling decorative or playful.
- Source Sans 3: Google Fonts — used for body and interface because it is readable, neutral, warm, and precise at the scaled-up sizes.
- JetBrains Mono: Google Fonts — used for code because it is compact, legible, and familiar in developer workflows.

## Google Fonts Import

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,560;9..144,600;9..144,620&family=JetBrains+Mono:wght@400;500&family=Source+Sans+3:wght@400;500;600;700&display=swap" rel="stylesheet">
```

```css
@import url('https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,560;9..144,600;9..144,620&family=JetBrains+Mono:wght@400;500&family=Source+Sans+3:wght@400;500;600;700&display=swap');

:root {
  --font-heading: 'Fraunces', Georgia, serif;
  --font-body: 'Source Sans 3', sans-serif;
  --font-interface: 'Source Sans 3', sans-serif;
  --font-code: 'JetBrains Mono', monospace;
}
```
