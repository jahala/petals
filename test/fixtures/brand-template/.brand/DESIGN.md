# larch Design System

<!--
  Template: DESIGN.md, the open 9-section design-system format (Apache 2.0)
  Fill each section from extracted brand values.
  Placeholders `{{...}}` are replaced during extraction.
-->

## 1. Visual Theme & Atmosphere

A calm paper planner: warm off-white pages, deep green ink for actions, one gold accent.

**Primary Attributes:**
- Calm
- Legible
- Warm

## 2. Color Palette & Roles

| Role | Hex | Usage |
|------|-----|-------|
| Primary | #2F6B4F | Actions and links |
| Accent | #C98A1B | Highlights and fills |
| Background | #F6F3EA | Page background |
| Text | #1F2A24 | Headings and body |
| Error | #B3402A | Errors |
| Success | #3F7D4E | Confirmations |

## 3. Typography Rules

| Level | Family | Weight | Size | Line Height | Letter Spacing |
|-------|--------|--------|------|-------------|----------------|
| h1 | Fraunces | 400 | 3rem | 1.1 | 0 |
| h2 | Fraunces | 400 | 2rem | 1.2 | 0 |
| body | Inter | 400 | 1rem | 1.6 | 0 |
| caption | Inter | 500 | 0.75rem | 1.4 | 0.02em |

## 4. Component Stylings

### Buttons
- **Primary:** Primary fill, background-colour text, radius-sm.
- **Secondary:** Transparent fill, 2px primary border, primary text.
- **States:** Hover deepens to primary (deep); focus shows a 2px primary outline.

### Cards
- Surface fill, hairline border, radius-lg.

### Inputs
- Background fill, border colour stroke, primary focus outline.

## 5. Layout Principles

- **Spacing Scale:** multiples of 4px, 4px to 64px (layout.md).
- **Grid:** 12 columns.
- **Max Width:** 1120px.
- **Whitespace Rhythm:** sections 48px to 64px apart.

## 6. Depth & Elevation

| Level | Shadow | Usage |
|-------|--------|-------|
| 0 | none | Flat page content |
| 1 | shadow-rest | Resting panes |
| 2 | shadow-lift | Hover lift |
| 3 | shadow-float | Floating panels |

## 7. Do's and Don'ts

### Do
- Use the primary colour for the one main action on a screen.
- Keep body text at 4.5:1 or more.
- Use the spacing scale.

### Don't
- Set words in moss or accent on the background.
- Add a second accent colour.
- Animate for attention.

## 8. Responsive Behavior

| Breakpoint | Min Width | Layout | Columns |
|------------|-----------|--------|---------|
| Mobile | 0 | Stacked | 1 |
| Tablet | 640px | Two-up | 6 |
| Desktop | 1024px | Full grid | 12 |
| Wide | 1024px | Full grid, centred | 12 |

## 9. Agent Prompt Guide

When generating UI or design output, follow these constraints:

1. **Colors:** Use only the palette defined in Section 2. Reference a colour by its token in `.brand/tokens.css` (`var(--larch-primary)`), never by raw hex.
2. **Typography:** Apply the hierarchy from Section 3. Never introduce fonts outside the defined families.
3. **Components:** Follow the styling rules in Section 4. Reuse patterns before inventing new ones.
4. **Spacing:** Adhere to the spacing scale in Section 5. Never use arbitrary pixel values.
5. **Elevation:** Apply shadow tokens from Section 6 by semantic level, not raw values.
6. **Responsive:** Start with mobile layout from Section 8, then enhance for larger breakpoints.
7. **Assets:** Source logos and images from .brand/assets/. Never invent placeholder logos.
8. **Voice:** Consult .brand/voice.md for copy. See .brand/colors.md for detailed color specs.
