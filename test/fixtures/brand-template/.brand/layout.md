# Layout: larch

<!--
  Template: layout.md
  How elements relate: spacing scale, containers, breakpoints, density.
  Every value must be stated in the source materials.
-->

## Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| 3xs | 4px | Icon padding |
| 2xs | 8px | Inline spacing |
| xs | 12px | Component inner |
| sm | 16px | Compact sections |
| md | 24px | Standard sections |
| lg | 32px | Major sections |
| xl | 48px | Page sections |
| 2xl | 64px | Hero spacing |

All spacing is a multiple of 4px.

## Containers & Measure

| Token | Value | Usage |
|-------|-------|-------|
| container | 1120px max-width, centered | The content container |
| gutter | 24px | Container horizontal padding |
| measure | 60ch | Reading-column width |

## Breakpoints

| Breakpoint | Token | What changes |
|------------|-------|--------------|
| 1024px | wide | Two-column layouts begin |
| 640px | narrow | Grids stack to one column |

## Density & Rhythm

- Sections sit 48px to 64px apart; a heading sits closer to its own content than to the section above.
