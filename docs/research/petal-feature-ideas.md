# Petal — Potential Features

**Created:** June 3, 2026
**Context:** Petal is an MCP service + skills toolkit that gives AI agents confident access to a company's brand identity — logos, typography, colors, imagery, illustrations, voice/tone, UI components, and more. Based on research of trybloom.ai, competitor analysis, market gaps, and first-principles thinking about what agents need.

---

## Guiding Principles

- **Agent-first** — every feature is callable by an AI agent via MCP, not just a human via UI
- **Comprehensive** — covers the FULL brand spectrum: code, copy, design, assets, voice
- **Open source** — self-hostable, inspectable, community-extensible
- **Stateless by default** — brand data lives in files (JSON/YAML/Markdown) in the repo; no SaaS dependency
- **SUPER architecture** — side effects at edges, uncoupled logic, pure functions, explicit data flow, referentially transparent

---

## Feature Categories

### A. Brand Onboarding & Extraction

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| A1 | **Website scraper** | Extract colors, fonts, logos, imagery from a URL | High |
| A2 | **Figma importer** | Read design tokens, components, styles from Figma files | High |
| A3 | **PDF/Image parser** | Extract brand elements from brand guidelines PDFs, moodboards | Medium |
| A4 | **Social media scraper** | Pull brand aesthetic from Instagram, etc. | Low |
| A5 | **Manual brand spec** | Human-authored brand definition files (brand.json, brand.md, brand.yaml) | High |
| A6 | **Guided brand interview** | Agent walks user through questions to define their brand interactively | Medium |

### B. Brand Data Model & Storage

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| B1 | **Canonical brand schema** | JSON Schema for brand definition — colors, typography, spacing, imagery, voice, components | High |
| B2 | **Brand file format** | `brand.json` + `brand.md` files that live in the repo | High |
| B3 | **Multi-brand support** | One project can define multiple brands (parent brand, sub-brands, product brands) | High |
| B4 | **Brand versioning** | Git-tracked brand changes with history | Medium |
| B5 | **Brand validation** | Validate brand definitions against schema; catch drift | Medium |
| B6 | **Brand inheritance** | Sub-brands inherit from parent, override selectively | Low |

### C. Design Tokens — Color, Typography, Spacing

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| C1 | **Color palette system** | Primary, secondary, accent, neutral, semantic (success, error, warning) with light/dark mode | High |
| C2 | **Typography scale** | Font families, weights, sizes, line heights, letter spacing — as structured data | High |
| C3 | **Spacing/sizing scale** | Design token spacing scale (4px base, etc.) | High |
| C4 | **Border radius tokens** | Standardized radius values | Medium |
| C5 | **Shadow/elevation tokens** | Box shadow presets mapped to elevation levels | Medium |
| C6 | **Animation/transition tokens** | Duration, easing curves as brand tokens | Low |

### D. Asset Management

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| D1 | **Logo variants** | Primary, alternate, mark-only, wordmark, monochrome, dark-mode variants | High |
| D2 | **Icon set catalog** | Brand-specific icon sets with metadata (name, category, tags) | Medium |
| D3 | **Image/photo library** | Brand photography with semantic tags and search | Medium |
| D4 | **Illustration style guide** | Illustration principles, examples, color palettes for illustrators | Low |
| D5 | **Pattern/texture library** | Brand patterns, textures, decorative elements | Low |

### E. Code Generation & Export

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| E1 | **CSS custom properties export** | Generate `--brand-*` CSS variables from brand tokens | High |
| E2 | **Tailwind config export** | Generate Tailwind `theme.extend` from brand tokens | High |
| E3 | **Design token JSON export** | W3C Design Tokens Community Group format | High |
| E4 | **TypeScript types export** | Generate TS types/interfaces for brand values | Medium |
| E5 | **Sass/SCSS variables export** | Generate SCSS variables | Medium |
| E6 | **Figma variables sync** | Push brand tokens to Figma as variables | Low |

### F. UI Component Guidance

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| F1 | **Component catalog** | Define available UI components with brand styling notes | High |
| F2 | **Component recommendation** | Agent asks "which component for [context]?" — returns best match | Medium |
| F3 | **Component usage examples** | Code snippets showing correct brand usage of each component | Medium |
| F4 | **Anti-patterns catalog** | "Don't use Component X for Y" rules | Low |

### G. Brand Voice & Copy

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| G1 | **Voice/tone definition** | Structured brand voice — formality, personality, vocabulary, grammar rules | High |
| G2 | **Copy snippets library** | Approved taglines, boilerplate, CTAs, microcopy | Medium |
| G3 | **Terminology glossary** | Approved terms, forbidden terms, preferred alternatives | Medium |
| G4 | **Tone adaptation rules** | How voice shifts for different contexts (marketing vs. docs vs. error messages) | Low |
| G5 | **Copy review agent** | Agent reviews generated copy against brand voice rules | Medium |

### H. MCP Server

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| H1 | **MCP server (stdio)** | Standard MCP server for Claude Desktop, Claude Code, etc. | High |
| H2 | **MCP server (HTTP/SSE)** | HTTP transport for remote agent access | Medium |
| H3 | **Tool: brand query** | Agent queries brand values — "what is our primary color?" | High |
| H4 | **Tool: brand search** | Semantic search across brand assets | Medium |
| H5 | **Tool: token export** | Agent requests design tokens in specific format | High |
| H6 | **Tool: component lookup** | Agent asks "which component should I use for a CTA?" | Medium |
| H7 | **Tool: voice check** | Agent submits copy, gets brand voice compliance score | Medium |
| H8 | **Tool: brand context injection** | Inject relevant brand context into agent's system prompt | High |

### I. Skills (Claude Code Skills)

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| I1 | **`/petal setup`** | Initialize petal in a project, create brand files | High |
| I2 | **`/petal extract`** | Extract brand from URL/Figma/PDF into brand files | High |
| I3 | **`/petal validate`** | Check existing UI against brand rules | Medium |
| I4 | **`/petal export`** | Export brand tokens to various formats | Medium |
| I5 | **`/petal review`** | Agent reviews PR/code for brand compliance | Medium |
| I6 | **`/petal voice`** | Check copy/messaging against brand voice | Low |

### J. Brand Compliance & Auditing

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| J1 | **CSS variable audit** | Scan codebase for hardcoded colors not using brand tokens | Medium |
| J2 | **Typography audit** | Detect font-family, size, weight deviations from brand | Medium |
| J3 | **Spacing audit** | Detect padding/margin values outside brand spacing scale | Low |
| J4 | **Component audit** | Detect custom components that duplicate brand-provided ones | Low |
| J5 | **Accessibility audit** | Brand color contrast, readable typography checks | Medium |

### K. Integrations & Ecosystem

| # | Feature | Description | Priority |
|---|---------|-------------|----------|
| K1 | **GitHub Action** | CI check that PRs don't break brand compliance | Medium |
| K2 | **VS Code extension** | In-editor brand hints and component suggestions | Low |
| K3 | **Figma plugin** | Sync between Figma and brand files | Low |
| K4 | **Storybook integration** | Auto-generate brand-aware Storybook theme | Low |

---

## Features Bloom Has That Petal Should NOT Clone

| Bloom Feature | Why Petal Shouldn't Copy |
|---------------|-------------------------|
| AI image generation | Commodity; every AI platform does this. Petal provides the brand context FOR generators. |
| Video generation | Outside scope; petal is brand intelligence, not media generation. |
| Credit/pricing system | Petal is open source; no usage metering needed. |
| SaaS-only hosting | Petal is self-hosted, file-based. |

---

## Feature Count Summary

| Category | Count |
|----------|-------|
| A. Brand Onboarding | 6 |
| B. Brand Data Model | 6 |
| C. Design Tokens | 6 |
| D. Asset Management | 5 |
| E. Code Generation & Export | 6 |
| F. UI Component Guidance | 4 |
| G. Brand Voice & Copy | 5 |
| H. MCP Server | 8 |
| I. Skills | 6 |
| J. Brand Compliance | 5 |
| K. Integrations | 4 |
| **Total** | **61** |

---

*This document will be refined as research continues and features are prioritized via tend.*
