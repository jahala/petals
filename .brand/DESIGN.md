# Plotplot Design System

## 1. Brand Foundation

| Field | Value |
|-------|-------|
| Name | Plotplot |
| Tagline | Grow what matters. |
| Mission | Help teams grow coherent companies by connecting product planning, brand consistency, market signals, and company memory. |
| Vision | A world where companies build with clearer direction, stronger coherence, and better awareness of the terrain around them. |
| Category | Company Coherence Platform |
| Positioning | Plotplot connects product planning, brand consistency, market signals, and company memory into one living strategic system. |

Plotplot is built around the idea that companies need a living map of what they are building, why they are building it, how they express it, and what the outside world is signaling back.

## 2. Visual Principles

| Principle | Description |
|-----------|-------------|
| Show relationships, not lists | Prioritise maps, links, clusters, dependencies, source trails, and cause-effect structures over isolated rows. |
| Make coherence visible | Show where strategy, roadmap, brand, signals, and decisions align, drift, duplicate, or contradict each other. |
| Prefer maps over dashboards | Dashboards report status. Plotplot should help teams navigate terrain and decide where to move next. |
| Make AI accountable | AI output must expose sources, confidence, reasoning summaries, and suggested human review points. |
| Support pruning | The system should help teams remove, merge, archive, simplify, and clarify — not only create more artifacts. |

## 3. Color System

The palette is a botanical archive: warm paper, dark soil, muted green labels, dried specimens, and occasional bloom-colored annotation marks. The shared primary palette is defined in `colors.md` and uses #4C5E3C as primary botanical green, #F7F1E6 as warm paper background, #211D17 as soil-black text, #EFE7D8 as card surface, #D8CCB8 as border, and #D97757 as restrained bloom clay accent.

Each product has its own muted accent color while keeping the same family feel. Root, Soil, Seed, Tend, Stem, Petal, Prune, Graft, Cultivate, Weather, Bloom, Harvest, and Canopy all have explicit hex values in `colors.md`. Use product accents for navigation markers, small badges, product headers, chart highlights, and focused states — not as full-screen theme replacements.

Dark mode should feel like dark soil at night, not a harsh developer theme. Use #17140F for dark backgrounds, #231F18 for surfaces, #EFE7D8 for text, and #453C30 for borders.

## 4. Typography System

Plotplot uses Google Fonts only. Headings and display use Fraunces — a warm, characterful serif with optical sizing and a soft axis, literate and botanical without being decorative. Body and interface use Source Sans 3 for readable, warm precision. Code uses JetBrains Mono for compact developer legibility.

The type scale is editorial and confident: the html base is 18px; h1 is a fluid clamp(3.4rem, 6vw, 4.6rem); h2 is 2.4rem; h3 is 1.6rem; h4 is 1.25rem; body is 1.0625rem with 1.65 line-height; small text is 0.9375rem; and code is 0.95rem. Display numerals run to 3.75rem. Full font weights, line heights, spacing values, and import URLs are defined in `typography.md`.

## 5. Spacing & Layout

All spacing uses a 4px grid. Tokens are 4xs 4px, 3xs 8px, 2xs 12px, xs 16px, sm 24px, md 32px, lg 48px, xl 64px, 2xl 96px, and 3xl 128px. Marketing sections breathe at the 96–128px end of the scale for vertical rhythm.

Layouts should feel calm and readable. Use generous whitespace, quiet grids, clear section boundaries, and visible relationships between objects. Avoid crowded dashboards, dense SaaS panels, decorative cards, and arbitrary spacing. Important strategic relationships should get spatial priority over raw data volume.

## 6. Component Foundations

Buttons should be restrained, direct, and legible. Primary buttons use #4C5E3C with #F7F1E6 text. Accent buttons use #D97757 only for high-momentum actions such as launch, publish, or confirm. Destructive buttons use #B85C3E.

Inputs should feel like annotated archive fields: warm surfaces, subtle borders, clear focus states, and plain labels. Use #EFE7D8 for input backgrounds, #D8CCB8 for borders, #4C5E3C for focus, and #211D17 for text.

Cards should group context, not decorate content. Use #EFE7D8 surfaces, #D8CCB8 borders, small product accent markers, and clear headings. Cards should expose source, owner, status, and relationship when relevant.

Navigation should make the portfolio understandable. Use product accents sparingly as section identifiers. Keep labels plain: Root, Soil, Seed, Tend, Stem, Petal, Prune, Graft, Cultivate, Weather, Bloom, Harvest, Canopy.

## 7. Iconography

Icons should feel like botanical diagrams, strategic maps, and system annotations. Use thin linework, rounded-but-not-cute geometry, small coordinate marks, nodes, roots, stems, plots, labels, and directional paths.

Avoid cartoon plants, emoji-like symbols, generic Material Design icons, sparkle icons, heavy filled shapes, and decorative AI motifs. Icons should clarify function before they express metaphor.

## 8. Illustration

Illustrations should mix botanical diagrams, strategic maps, system sketches, and field notes. Use thin linework, subtle grids, muted fills, annotation marks, labels, plotted zones, root-like networks, and signal points.

The illustration system should feel like an intelligent archive rather than a playful garden. It can be warm and poetic, but it must remain useful, structured, and literate. Avoid mascots, smiling objects, cartoon leaves, glossy gradients, and generic futuristic AI visuals.

## 9. Motion

Motion should be subtle, calm, and informative. Use short fades, gentle reveals, map-like expansions, quiet state transitions, and source-trail highlighting. Movement should help users understand relationship, sequence, or change.

Avoid bouncy transitions, flashy animations, confetti, pulsing hype effects, excessive parallax, and motion that suggests urgency where none exists. The product should feel alive, not restless.
