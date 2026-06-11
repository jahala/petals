# Plotplot Brand Brief — for agent production

Produce a complete, extractable brand identity for **Plotplot** that a machine
(petals) can read and an AI coding agent can apply to UI/copy output.

Output format: a `/brand-assets/` directory with these exact files.

---

## 1. `colors.md`

Use this exact template:

```markdown
# Brand Colors — Plotplot

## Primary Palette

| Role | Hex | RGB | Usage |
|------|-----|-----|-------|
| Primary | #XXXXXX | rgb(?, ?, ?) | ... |
| Accent | #XXXXXX | rgb(?, ?, ?) | ... |
| Background | #XXXXXX | rgb(?, ?, ?) | ... |
| Text | #XXXXXX | rgb(?, ?, ?) | ... |
| Surface | #XXXXXX | rgb(?, ?, ?) | ... |
| Border | #XXXXXX | rgb(?, ?, ?) | ... |

## Semantic Roles

| Role | Hex | Usage |
|------|-----|-------|
| Error | #XXXXXX | ... |
| Success | #XXXXXX | ... |
| Warning | #XXXXXX | ... |
| Info | #XXXXXX | ... |

## Product Accents

Each product in the Plotplot portfolio has its own accent. The primary palette
is shared across all products.

| Product | Accent Hex | Role |
|---------|-----------|------|
| Root | #XXXXXX | Foundation |
| Soil | #XXXXXX | Memory |
| Seed | #XXXXXX | Ideas |
| Tend | #XXXXXX | Roadmap |
| Stem | #XXXXXX | Strategy |
| Petal | #XXXXXX | Brand |
| Prune | #XXXXXX | Clarity |
| Graft | #XXXXXX | Integration |
| Cultivate | #XXXXXX | Signals |
| Weather | #XXXXXX | Risk |
| Bloom | #XXXXXX | Launch |
| Harvest | #XXXXXX | Outcomes |
| Canopy | #XXXXXX | Leadership |

## Light / Dark Mode Variants

| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Primary | #XXXXXX | #XXXXXX |
| Background | #XXXXXX | #XXXXXX |
| Text | #XXXXXX | #XXXXXX |
| Surface | #XXXXXX | #XXXXXX |
| Border | #XXXXXX | #XXXXXX |

## CSS Custom Properties

```css
:root {
  --color-primary: #XXXXXX;
  --color-accent: #XXXXXX;
  --color-background: #XXXXXX;
  --color-text: #XXXXXX;
  --color-surface: #XXXXXX;
  --color-border: #XXXXXX;
  --color-error: #XXXXXX;
  --color-success: #XXXXXX;
  --color-warning: #XXXXXX;
  --color-info: #XXXXXX;
}
```
```

### Concrete asks for colors

1. **Primary** — a moss green. Should feel calm, organic, strategic. Not neon.
   Not military. Think: sage, olive, forest-muted. Give an exact hex.

2. **Background** — a warm off-white, not pure white. Slightly paper-like.
   Think: cream, parchment, warm paper. Give an exact hex.

3. **Text** — a deep charcoal / soil black. Not pure #000. Slightly warm.
   Think: damp earth, dark soil, charcoal with brown undertone. Give an exact hex.

4. **Surface** — a very light warm neutral for cards/panels. Slightly darker
   than background. Give an exact hex.

5. **Border** — a subtle warm grey for dividers. Give an exact hex.

6. **Accent** — bloom coral. Used sparingly for highlights, CTAs, momentum.
   Should feel warm, energetic but not screaming. Think: dried flower, muted
   coral, dusty rose. Give an exact hex.

7. **Semantic colors** — error (red-tinged but muted), success (moss-adjacent
   green), warning (warm ochre/gold), info (muted blue). All must feel like
   they belong in the same earthy/restrained palette. Give exact hex codes.

8. **Product accents** — 13 products listed in the table above. Each gets a
   unique accent hex that distinguishes it within the Plotplot family. The
   accents share the same muted/earthy quality. Petal should be a soft coral
   variant. Tend should be moss-adjacent. Bloom should be the most vibrant
   but still restrained. Give exact hex for each.

9. **Dark mode variants** — for primary, background, text, surface, and
   border. Should be dark but warm — not pure black, not harsh. Think: dark
   soil at night, not developer-dark-theme.

**Color philosophy:** The palette should feel like walking through a botanical
archive — warm paper, dark ink, dried specimens, muted green labels, the
occasional bloom-colored annotation mark. Nothing fluorescent. Nothing that
screams "SaaS." Restrained, literate, warm, strategic.

---

## 2. `typography.md`

Use this exact template:

```markdown
# Typography — Plotplot

## Font Families

| Role | Font Family | Weight | Style |
|------|------------|--------|-------|
| Headings | [Name] | [weight] | [normal/italic] |
| Body | [Name] | [weight] | [normal/italic] |
| Interface | [Name] | [weight] | [normal/italic] |
| Code | [Name] | [weight] | [normal/italic] |

## Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | 400 | Body, interface |
| Medium | 500 | Labels, small headings |
| Semibold | 600 | Subheadings |
| Bold | 700 | Headings |

## Type Scale

| Level | Size | Line Height | Weight | Usage |
|-------|------|------------|--------|-------|
| h1 | XXpx | 1.2 | Bold | Page titles |
| h2 | XXpx | 1.25 | Bold | Section headings |
| h3 | XXpx | 1.3 | Semibold | Subsection headings |
| h4 | XXpx | 1.35 | Semibold | Card titles |
| body | XXpx | 1.5 | Regular | Body text |
| small | XXpx | 1.4 | Regular | Captions, labels |
| code | XXpx | 1.5 | Regular | Code blocks |

## Spacing Scale

Multiples of 4px:

| Token | Value | Usage |
|-------|-------|-------|
| 4xs | 4px | Tight icon padding |
| 3xs | 8px | Inline spacing |
| 2xs | 12px | Component inner |
| xs | 16px | Compact section |
| sm | 24px | Standard section |
| md | 32px | Major section |
| lg | 48px | Page sections |
| xl | 64px | Hero spacing |
| 2xl | 96px | Layout breaks |

## Font Sources

- [Font Name]: [Google Fonts / commercial / source URL]
- [Font Name]: [source]
```

### Concrete asks for typography

1. **Heading font** — a distinctive grotesk or humanist sans with character.
   Must be available on Google Fonts (free, easy to use in web projects).
   Suggestions to consider: Work Sans, Sora, DM Sans, Outfit, Public Sans.
   Pick ONE. Give its exact Google Fonts name and a 1-line rationale.

2. **Body font** — highly readable neutral sans. Must pair well with the
   heading font. Available on Google Fonts. Suggestions: Inter, DM Sans
   (if heading is different), Source Sans 3, Figtree. Pick ONE.

3. **Interface font** — compact, precise. Can be same as body or a tighter
   variant. Pick ONE.

4. **Code font** — monospace. Suggestions: JetBrains Mono, Fira Code, IBM
   Plex Mono. Pick ONE.

5. **Type scale** — fill in the actual px sizes for each level. h1 should
   feel editorial but not gigantic. Body should be comfortably readable.
   Code should be legible at smaller sizes.

6. **Google Fonts import URL** — provide the exact `<link>` or `@import`
   for all chosen fonts with correct weights.

**Typography philosophy:** The fonts should feel like an archive, a botanical
journal, a strategic map. Clean, precise, slightly warm. Not cold Helvetica.
Not playful rounded. Not pixel-perfect engineering. A humanist quality that
says "serious work happens here, with care."

---

## 3. `voice.md`

Use this exact template:

```markdown
# Voice & Tone — Plotplot

## Brand Voice

Plotplot speaks with **[adjective]** **[adjective]** **[adjective]**.

## Personality Traits

| Trait | More | Less |
|-------|------|------|
| ... | ... | ... |

## Tone

| Trait | Description |
|-------|------------|
| Clarity | ... |
| Warmth | ... |
| Precision | ... |

## Forbidden Terms

Never use these words in Plotplot copy:

| Term | Reason | Use Instead |
|------|--------|------------|
| ... | ... | ... |

## Before / After Examples

| Context | Before (bad) | After (good) |
|---------|-------------|---------------|
| Marketing headline | ... | ... |
| Feature description | ... | ... |
| Error message | ... | ... |
| Dashboard label | ... | ... |
| Notification | ... | ... |

## Context-Specific Adaptations

### Product Interface
...

### Marketing / Landing Pages
...

### Error Messages
...

### AI Agent Output
...
```

### Concrete asks for voice

1. **Voice summary** — fill in the three adjectives. From the draft: "calm
   clarity," "plain, precise, slightly poetic." Pick 3 that capture it.

2. **Personality traits** — 4-5 rows in the More/Less table. From the draft:
   intelligent not corporate, organic not cute, calm but sharp, opinionated
   not arrogant. Turn these into the table.

3. **Forbidden terms** — list at least 8 words Plotplot must never use. From
   the draft's "bad voice" section: "supercharge," "unlock," "10x," "magic,"
   "synergy"/"synergize," "growth engine," "revolutionary." Add more that
   would violate the calm/restrained/literate quality.

4. **Before/after examples** — 5 pairs minimum. Use the draft's examples as
   seeds. The "bad" column should sound like generic SaaS AI hype. The "good"
   column should sound like Plotplot. Include: marketing headline, feature
   description, error message, dashboard label, notification.

5. **Context adaptations** — 1-2 sentences each for product interface,
   marketing, errors, and AI agent output. How does the voice shift in each?

**Voice philosophy:** Plotplot should sound like a sharp, literate strategist
who has spent years in product — not a marketing intern, not a hype merchant,
not a bot. Plain sentences. Occasional poetry when the insight warrants it.
Never techno-optimist jargon. Never forced warmth.

---

## 4. `identity.md`

Use this exact template:

```markdown
# Brand Identity — Plotplot

| Field | Value |
|-------|-------|
| Brand Name | Plotplot |
| Tagline | Grow what matters. |
| Mission | ... |
| Vision | ... |
| Founded | 2026 |
| Brand Version | v1.0.0 |
```

### Concrete asks for identity

1. **Mission** — one sentence. What Plotplot exists to do. From the draft:
   "Help teams grow coherent companies." Refine it.

2. **Vision** — one sentence. The world Plotplot wants to create.

3. **Story** — add a "Brand Story" section. 3-4 paragraphs. From the draft's
   Section 15 (Brand Narrative). Tell the story of why Plotplot exists — the
   problem of scattered context, fragmented decisions, and companies growing
   in different directions.

---

## 5. `DESIGN.md`

Use the 9-section Google Stitch template. Fill in:

1. **Brand Foundation** — name, tagline, mission, vision, category ("Company
   Coherence Platform"), one-line positioning.

2. **Visual Principles** — 4-5 principles. From the draft: show relationships
   not lists, make coherence visible, prefer maps over dashboards, make AI
   accountable, support pruning.

3. **Color System** — summary of the palette, philosophy, product accent
   system. Reference colors.md for the full table.

4. **Typography System** — summary of font choices, scale, philosophy.
   Reference typography.md for the full table.

5. **Spacing & Layout** — the 4px grid system. Layout principles.

6. **Component Foundations** — buttons, inputs, cards, navigation. Describe
   the philosophy (restrained, literate, warm).

7. **Iconography** — style direction. From the draft: botanical diagrams,
   thin linework, annotation marks. Not cartoon, not Material Design.

8. **Illustration** — style direction. From the draft: botanical diagrams,
   strategic maps, system sketches, field notes. Thin linework, subtle grids,
   muted fills, annotation marks.

9. **Motion** — subtle, calm. No bouncy transitions. No flash.

**DESIGN.md philosophy:** This is the master document. A new developer should
be able to read DESIGN.md and understand how Plotplot looks, feels, and
behaves. Colors.md, typography.md, voice.md, and identity.md are the
machine-readable reference files. DESIGN.md is the human-readable synthesis.

---

## Output directory structure

```
/brand-assets/
  DESIGN.md         ← 9 Google Stitch sections, filled in
  colors.md         ← complete palette with hex codes, CSS vars, product accents
  typography.md     ← exact font names, weights, scale, spacing, imports
  voice.md          ← forbidden terms, before/after, context adaptations
  identity.md       ← name, tagline, mission, vision, story
```

---

## Design constraints

- Every hex code must be explicit. No "moss green" without a hex.
- Every font must be named. No "a distinctive grotesk" without the exact name.
- Every forbidden term must be explicit. No "avoid hype words."
- Google Fonts only — free, embeddable, no licenses to manage.
- The output files must be readable by petals' extraction guide. This means:
  table-format colors, explicit font family names, explicit hex codes,
  explicit px values for spacing. No hand-waving.
- The palette must work in light AND dark mode.
- The 13 product accents must be visually distinguishable from each other
  while remaining within the same earthy/restrained quality.
