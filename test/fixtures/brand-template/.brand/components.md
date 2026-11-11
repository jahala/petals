# Surface & Motion: larch

<!--
  Template: components.md
  Machine-readable surface and motion tokens: radius, borders, shadows,
  easings, durations, component conventions.
-->

## Radius Scale

| Token | Value | Usage |
|-------|-------|-------|
| radius-xs | 2px | Focus rings, chips |
| radius-sm | 4px | Buttons, inputs |
| radius-md | 8px | Panels |
| radius-lg | 12px | Cards |
| radius-full | 999px | Pills, badges, dots |

## Border Strokes

| Token | Value | Usage |
|-------|-------|-------|
| stroke-hairline | 1px solid | Structural borders, dividers |
| stroke-emphasis | 2px | Emphasized borders, underlines |
| stroke-rule | 3px | Accent rules, markers |

## Shadow Recipes

Shadows are ink-tinted: `rgba(31, 42, 36, …)`, never pure black.

| Token | Value | Usage |
|-------|-------|-------|
| shadow-rest | `0 1px 2px rgba(31, 42, 36, 0.08)` | Resting panes |
| shadow-lift | `0 4px 16px rgba(31, 42, 36, 0.12)` | Hover lift |
| shadow-float | `0 12px 32px rgba(31, 42, 36, 0.16)` | Floating panels |

## Motion Tokens

| Token | Value | Usage |
|-------|-------|-------|
| ease | cubic-bezier(0.2, 0, 0, 1) | Entrances and settles |
| dur-entrance | 0.4s | Section and card entrances |
| dur-micro | 0.15s | Hovers, colour shifts |
| stagger-step | 0.05s | Sibling delay inside groups |

Rules:

- Motion explains a change; nothing moves for attention.
- `prefers-reduced-motion: reduce` MUST disable all entrances and staggers.
- Forbidden: bounce easings, looping attention effects, parallax.

## Component Conventions

| Component | Convention |
|-----------|------------|
| Button (primary) | Primary fill, background-colour text, radius-sm, weight 600 |
| Card | Surface fill, stroke-hairline border, radius-lg |
| Focus state | 2px solid primary outline, 2px offset |

## Applying in frameworks

The brand wins over framework defaults. Mirror tokens as CSS custom
properties; extend a CSS framework's theme (`borderRadius`, `boxShadow`,
`transitionTimingFunction`) instead of using stock utilities; override
component-library theme variables once at the theme layer.
