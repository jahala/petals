# Test Brand Design System

## 1. Visual Theme & Atmosphere

Clean, modern, accessible. Minimalist with warm accents.

**Primary Attributes:**
- Clean and approachable
- High contrast for readability
- Consistent spacing rhythm

## 2. Color Palette & Roles

| Role | Hex | Usage |
|------|-----|-------|
| Primary | #2F99A4 | Primary actions, headers, brand elements |
| Accent | #E8A838 | Highlights, CTAs, focus states |
| Background | #FFFFFF | Page backgrounds, cards |
| Text | #1A1A1A | Body text, labels |
| Error | #D14343 | Error messages, destructive actions |
| Success | #47B881 | Success messages, confirmations |

## 3. Typography Rules

| Level | Family | Weight | Size | Line Height | Letter Spacing |
|-------|--------|--------|------|-------------|----------------|
| h1 | Inter | 700 | 36px | 1.2 | -0.5px |
| h2 | Inter | 600 | 24px | 1.3 | 0 |
| body | Inter | 400 | 16px | 1.5 | 0 |
| caption | Inter | 400 | 12px | 1.4 | 0.2px |

## 4. Component Stylings

### Buttons
- **Primary:** bg #2F99A4, white text, 8px radius
- **Secondary:** 1px border #2F99A4, transparent bg
- **States:** hover: darken 10%, focus: 2px outline

### Cards
- 8px radius, 1px border #E6E6E6, 16px padding

### Inputs
- 6px radius, 1px border #CCCCCC, 12px padding

## 5. Layout Principles

- **Spacing Scale:** 4px base (4, 8, 16, 24, 32, 48, 64)
- **Grid:** 12-column, 24px gutter
- **Max Width:** 1200px
- **Whitespace Rhythm:** Multiples of 8px

## 6. Depth & Elevation

| Level | Shadow | Usage |
|-------|--------|-------|
| 0 | none | Flat content |
| 1 | 0 1px 3px rgba(0,0,0,0.12) | Cards |
| 2 | 0 4px 12px rgba(0,0,0,0.16) | Dropdowns, tooltips |
| 3 | 0 8px 24px rgba(0,0,0,0.2) | Modals |

## 7. Do's and Don'ts

### Do
- Use the spacing scale consistently
- Maintain WCAG AA contrast minimum
- Follow the typographic hierarchy

### Don't
- Use arbitrary color values outside the palette
- Mix spacing units (px with rem)
- Shrink body text below 12px

## 8. Responsive Behavior

| Breakpoint | Min Width | Layout | Columns |
|------------|-----------|--------|---------|
| Mobile | 0 | Stack | 4 |
| Tablet | 768px | Hybrid | 8 |
| Desktop | 1024px | Full | 12 |
| Wide | 1440px | Full | 12 |

## 9. Agent Prompt Guide

When generating UI or design output, follow these constraints:

1. **Colors:** Use only the palette defined in Section 2. Reference by semantic role, not raw hex.
2. **Typography:** Apply the hierarchy from Section 3. Never introduce fonts outside the defined families.
3. **Components:** Follow the styling rules in Section 4. Reuse patterns before inventing new ones.
4. **Spacing:** Adhere to the spacing scale in Section 5. Never use arbitrary pixel values.
5. **Elevation:** Apply shadow tokens from Section 6 by semantic level, not raw values.
6. **Responsive:** Start with mobile layout from Section 8, then enhance for larger breakpoints.
7. **Assets:** Source logos and images from .brand/assets/. Never invent placeholder logos.
8. **Voice:** Consult .brand/voice.md for copy. See .brand/colors.md for detailed color specs.
