# Brand Colors: larch

<!--
  Template: colors.md
  Every colour value must be stated in the source materials as a hex, RGB or
  CMYK value. Do not infer a hex from a colour name or a visual sample.

  petals' scripts read this file. check.sh judges pages against every hex in
  it and against the Contrast Pairings table. export-tokens.sh derives the
  colour tokens from the CSS block at the end. Keep the headings and the table
  columns as they are, and write each hex with six digits.
-->

## Primary Palette

| Role | Hex | RGB | CMYK | Usage |
|------|-----|-----|------|-------|
| Primary | #2F6B4F | rgb(47,107,79) | not specified | Primary actions, links, selected states |
| Primary (deep) | #24543E | rgb(36,84,62) | not specified | Hover and pressed states of primary |
| Accent | #C98A1B | rgb(201,138,27) | not specified | Highlights and fills with text-colour words; never text on paper |
| Text | #1F2A24 | rgb(31,42,36) | not specified | Headings and body |
| Text (soft) | #56645B | rgb(86,100,91) | not specified | Secondary copy, captions |
| Background | #F6F3EA | rgb(246,243,234) | not specified | Page background |
| Surface | #EDE8DA | rgb(237,232,218) | not specified | Cards and panels |
| Border | #D6CFBC | rgb(214,207,188) | not specified | Dividers and input borders |
| Moss | #628C6C | rgb(98,140,108) | not specified | Illustration fills only; never text |

## Semantic Roles

| Role | Hex | Usage |
|------|-----|-------|
| Error | #B3402A | Validation errors, destructive actions |
| Success | #3F7D4E | Confirmations, passing checks |
| Warning | #9A6A12 | Caution and incomplete setup |
| Info | #3B6A8A | Informational notices |

## Light / Dark Mode Variants

| Role | Light | Dark |
|------|-------|------|
| Primary | #2F6B4F | #7FC29B |
| Accent | #C98A1B | #E0A83A |
| Text | #1F2A24 | #ECE8DC |
| Text (soft) | #56645B | #B5B9AE |
| Background | #F6F3EA | #141A16 |
| Surface | #EDE8DA | #1D2520 |
| Border | #D6CFBC | #34403A |

## Usage Rules

- Primary colour occupies about 10% of the visible UI.
- Accent colour is for highlights and the one fill that marks a new thing.
- Never use the error colour for a state that is not an error.
- Body text meets 4.5:1 against its background; labels and large display type meet 3:1.

## Contrast Pairings

Classes: **reading** at least 4.5:1 (body copy, captions), **labels** at least 3.0:1 (labels, tags, type of 24px and up), **decorative** never words (marks, fills, washes).

| Foreground on background | Ratio | Class |
|---|---|---|
| Text #1F2A24 on Background #F6F3EA | 13.38 | reading |
| Text #1F2A24 on Surface #EDE8DA | 12.13 | reading |
| Text (soft) #56645B on Background #F6F3EA | 5.62 | reading |
| Primary #2F6B4F on Background #F6F3EA | 5.67 | reading |
| Background #F6F3EA on Primary #2F6B4F | 5.67 | reading |
| Text #1F2A24 on Accent #C98A1B | 5.04 | reading |
| Warning #9A6A12 on Background #F6F3EA | 4.26 | labels |
| Accent #C98A1B on Background #F6F3EA | 2.65 | decorative |
| Moss #628C6C on Background #F6F3EA | 3.45 | decorative |
| Text #ECE8DC on Background #141A16 | 14.42 | reading |
| Primary #7FC29B on Background #141A16 | 8.49 | reading |

## Forbidden Combinations

- Accent text on the background: 2.65:1, below every class but decorative.
- Moss text anywhere: it is a fill colour.

## CSS Custom Properties

```css
:root {
  /* primary palette */
  --larch-primary: #2F6B4F;
  --larch-primary-deep: #24543E;
  --larch-accent: #C98A1B;
  --larch-text: #1F2A24;
  --larch-text-soft: #56645B;
  --larch-bg: #F6F3EA;
  --larch-surface: #EDE8DA;
  --larch-border: #D6CFBC;
  --larch-moss: #628C6C;

  /* semantic */
  --larch-error: #B3402A;
  --larch-success: #3F7D4E;
  --larch-warning: #9A6A12;
  --larch-info: #3B6A8A;
}

[data-theme="dark"] {
  --larch-primary: #7FC29B;
  --larch-accent: #E0A83A;
  --larch-text: #ECE8DC;
  --larch-text-soft: #B5B9AE;
  --larch-bg: #141A16;
  --larch-surface: #1D2520;
  --larch-border: #34403A;
}
```
