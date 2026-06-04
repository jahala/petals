# Desygnr Deep Dive — What We Can Reuse for Petal

**Analysis Date:** June 3, 2026
**Location:** `~/.claude/marketplaces/local-plugins/desygnr/`
**Version:** 3.1.0 (November 2025)

---

## Architecture Overview

```
desygnr/
├── index.js                          # CLI (extract + audit commands)
├── .mcp.json                         # MCP server config
├── .claude-plugin/plugin.json        # Plugin manifest
├── agents/                           # 7 specialized agents
│   ├── color-system-designer/        # CREATE color systems
│   ├── component-designer/           # CREATE component architectures
│   ├── color-auditor/                # ANALYZE color usage
│   ├── design-system-doctor/         # DIAGNOSE design health
│   ├── component-extractor/          # REFACTOR duplicates
│   ├── design-replicator/            # REPLICATE from reference sites
│   └── design-system-guardian/       # ENFORCE via pre-tool-use hook
├── .agent-shared/                    # Shared ecosystem context
├── src/
│   ├── mcp-server.js                 # 6 MCP tools (1041 lines)
│   ├── analyzer.js                   # Main orchestrator
│   ├── analyzers/                    # 10 analysis modules
│   │   ├── colors.js                 # Semantic color usage tracking, deltaE
│   │   ├── typography.js
│   │   ├── spacing.js
│   │   ├── components.js
│   │   ├── component-similarity.js   # Weighted similarity, O(n²) clustering
│   │   ├── component-patterns.js
│   │   ├── animations.js
│   │   ├── icons.js
│   │   ├── shadows.js
│   │   ├── templates.js              # Information architecture analysis
│   │   ├── interactive-states.js
│   │   ├── sections.js
│   │   └── inconsistencies.js
│   ├── browser-extractors/           # 6 Playwright-based extractors
│   │   ├── index.js                  # Orchestrator
│   │   ├── fonts.js
│   │   ├── css-vars.js
│   │   ├── icons.js
│   │   ├── animations.js
│   │   ├── interactive.js
│   │   └── sections.js
│   ├── core/                         # Core infrastructure
│   │   ├── browser-manager.js         # Playwright lifecycle
│   │   ├── design-system-generator.js # Aggregation engine
│   │   ├── page-discoverer.js         # Sitemap + link crawling
│   │   └── page-scraper.js
│   ├── exporters/                    # 3 output formats
│   │   ├── json.js
│   │   ├── markdown.js               # 526 lines - comprehensive report
│   │   └── multi-file.js             # 505 lines - organized structure
│   ├── cli/                          # CLI commands
│   └── utils/
│       └── paths.js
└── docs/                             # Sample outputs, templates
```

**Scale:** ~31,000 total lines (9,381 agent definitions + ~7,000 source JS + docs/changelog)

---

## MCP Tools (6)

| # | Tool | What It Does | Code Lines |
|---|------|-------------|------------|
| 1 | `extract_design_system` | Headless browser → full design system JSON. Analyzes colors (OKLCH→RGB), typography, components, spacing, sections, icons, animations, interactive states. Multi-page with breakpoint support. | ~100 |
| 2 | `audit_design_system` | Compare live site against reference design-system.json. Detects color/typo/spacing/component deviations. | ~60 |
| 3 | `generate_design_reference` | Generate LLM-optimized constraints document from design system. Semantic usage patterns, component opportunities, code examples. | ~80 |
| 4 | `extract_component_opportunities` | Cluster similar components using weighted similarity (structure, styles, colors, typo, layout). Returns prioritized refactoring opportunities with ROI. | ~70 |
| 5 | `generate_tailwind_config` | Convert design system → Tailwind v3 config (colors, fontFamily, spacing, plugins). | ~60 |
| 6 | `validate_component` | Validate component code (JSX/HTML/Vue) against design system. Checks hardcoded colors, spacing values. Strict/warning modes. | ~80 |

---

## Agents (7) — Deep Capability Map

### Creation Agents

#### 1. color-system-designer (1,635 lines)
- **Input:** Raw hex codes, color names, Figma exports
- **Output:** Complete color system with hierarchy, scales, accessibility, implementation
- **Capabilities:**
  - HSL property analysis (hue, saturation, lightness)
  - Color categorization (bold, neutral, vibrant, muted)
  - Temperature analysis (warm vs cool)
  - Visual weight calculation
  - 60-30-10 proportion mapping
  - Semantic role assignment (primary/secondary/accent/neutral + success/error/warning/info)
  - Full color scales (50-900) with proper lightness curves
  - WCAG AA/AAA contrast testing for all combinations
  - Usage guidelines (when to use, when NOT to use, proportion, max per screen)
  - Implementation generation: `tailwind.config.js`, `design-tokens.css`, `design-tokens.json`
  - Component usage examples
  - Team documentation (hierarchy, weight, semantics, do's/don'ts, quick reference)
  - Context-aware: brand personality, industry constraints, team capabilities

#### 2. component-designer (1,893 lines)
- **Input:** Requirements, existing design system
- **Output:** Component library architecture + implementation templates
- **Capabilities:**
  - Component library architecture (atoms/molecules/organisms)
  - API design with variants, states, sizes, loading/disabled/error
  - Design system integration (reads color-system-designer output)
  - Composition patterns (compound components, slots, render props, context)
  - Micro-component principle (3-5 props max, single responsibility)
  - Accessibility patterns (ARIA, semantic HTML, keyboard nav, focus management)
  - Implementation templates (TypeScript interfaces, component code, stories)
  - Documentation (API reference, usage examples, do's/don'ts, accessibility notes)
  - 12 guiding principles for pragmatic component design

### Analysis Agents

#### 3. color-auditor (1,443 lines)
- **Input:** Page URL or codebase path
- **Output:** Color audit report with prioritized fixes
- **Capabilities:**
  - Smart analysis decision tree (source code vs rendered site)
  - Quick analysis for Tailwind projects (grep classNames)
  - Deep analysis via `extract_design_system` MCP tool
  - "Rainbow mess" detection — pages/sections with >15 unique colors
  - Per-page / per-section color variety counts
  - Context-aware thresholds (landing pages 8-12, marketing 10-15, internal tools 12-18)
  - Color consolidation mapping (47 blues → 3 blues with migration path)
  - Off-palette color detection
  - WCAG AA/AAA contrast checking
  - Semantic pattern recognition (status, emphasis, categories)
  - Color health scoring
  - Two-phase scan strategy for large sites

#### 4. design-system-doctor (1,137 lines)
- **Input:** Design system from `extract_design_system`
- **Output:** Health report with root cause analysis and phased action plans
- **Capabilities:**
  - Health scoring with weighted criteria
  - Prioritized issue list (critical/medium/low)
  - Root cause analysis (not just symptoms)
  - Evidence-based recommendations (usage counts, impact metrics)
  - Triage-first approach (top 3 critical issues, not all 47)
  - Incremental improvement plans (Phase 1/2/3)
  - Context-aware (team size, timeline, business priorities)
  - 12 diagnostic principles

#### 5. component-extractor (1,193 lines)
- **Input:** Existing codebase
- **Output:** Duplicate detection + refactoring plan
- **Capabilities:**
  - Weighted similarity scoring (structure, styles, colors, typo, layout)
  - 4 refactoring levels (Manual fixes → Micro-components → Page sections → Config-driven)
  - Rule of Three enforcement (don't abstract <3 repetitions)
  - Micro-component extraction (small, focused, single-responsibility)
  - Co-location principle (keep content near where rendered)
  - Migration scripts
  - 7 guiding principles against over-abstraction

### Replication Agent

#### 6. design-replicator (1,089 lines)
- **Input:** Reference URL (e.g., stripe.com, linear.app)
- **Output:** Extracted patterns adapted to user's system
- **Capabilities:**
  - Pattern extraction (not cloning — adapts patterns, not implementations)
  - Simplification (reference sites often over-engineered)
  - Framework adaptation (React patterns for React, not jQuery)
  - Content/structure separation
  - Accessibility correction (don't replicate a11y mistakes)
  - 10 guiding principles for replication

### Enforcement Agent

#### 7. design-system-guardian (991 lines + pre-tool-use hook)
- **Trigger:** Pre-tool-use hook (automatic on significant UI changes)
- **Capabilities:**
  - Progressive enforcement: strict for new code, understanding for legacy, permissive for prototypes
  - Color validation (hardcoded hex → palette match suggestion)
  - Typography hierarchy enforcement
  - Spacing consistency checks
  - Component reuse suggestions (detects duplicates)
  - Auto-fix offers ("I can update this to use design system color")
  - Exception tracking with documentation
  - Context-aware: landing pages (strict) vs internal tools (flexible) vs prototypes (permissive)
  - 12 enforcement principles

---

## What Desygnr Does Well (Things to Inherit)

| Pattern | Why It Works |
|---------|-------------|
| **MCP server as the backbone** | stdio transport, 6 focused tools, clean parameter schemas |
| **7-agent ecosystem with clear boundaries** | Each agent has ONE job. Creation vs Analysis vs Enforcement are separate concerns. |
| **Ecosystem awareness** | Agents know about each other, can delegate via Task tool, read each other's outputs |
| **Smart analysis decision trees** | Quick (source code grep) vs Deep (headless browser) — right tool for the context |
| **LLM-optimized constraints document** | Compact, structured, machine-readable brand reference for injection into agent context |
| **Playwright-based extraction** | Real browser rendering = accurate computed styles, not just source CSS |
| **OKLCH→RGB color pipeline** | Perceptually uniform color space for similarity matching |
| **Progressive enforcement philosophy** | Strict on fundamentals, flexible on details, permissive on prototypes |
| **Multi-format export** | JSON (machines), Markdown (humans), Multi-file (both) |
| **Tailwind version awareness** | Detects v3 vs v4, generates correct config format |

---

## What Desygnr Is Missing (Petal Opportunities)

| Gap | Petal Should Build |
|-----|-------------------|
| **No brand file format** — extracts from live sites only, doesn't create a portable brand spec | `brand.json` + `brand.md` that lives in the repo |
| **No brand voice/tone** — entirely visual/aesthetic focused | Structured voice/tone rules, terminology glossary, copy review |
| **No design token export beyond Tailwind/CSS** | W3C DTCG, Figma variables, TypeScript types, Style Dictionary |
| **No CI integration** | GitHub Action for brand compliance on PRs |
| **No brand versioning** | Git-tracked brand changes with diff awareness |
| **Browser-dependent extraction** — requires Playwright, heavyweight | Lighter extraction modes (CSS parsing, no browser for simple cases) |
| **No multi-brand support** | One design system at a time; no parent/sub-brand hierarchy |
| **Component validation is basic** — regex for hardcoded colors | AST-aware validation, component tree analysis |
| **No Figma sync** — extraction from Figma but no push-back | Bidirectional Figma ↔ brand spec sync |
| **No Storybook integration** | Auto-generate brand-aware Storybook theme |
| **Agents are Claude Code-specific** | Should work with any MCP-compatible client |
| **No semantic brand search** | Vector search across all brand assets |
| **No logo management** — notices logos exist, but no variant/format handling | Logo variant catalog with format/mode filters |
| **No illustration style guide** | Illustration principles, color palettes for illustrators |

---

## What Petal Should Directly Reuse from Desygnr

### Code to Extract/Rewrite:

| Module | Lines | Reuse Strategy |
|--------|-------|---------------|
| `src/analyzers/colors.js` | 428 | Lift the semantic color tracking, deltaE comparison, OKLCH pipeline |
| `src/analyzers/typography.js` | 165 | Font family detection, scale extraction |
| `src/analyzers/spacing.js` | 92 | Spacing scale detection, base unit calculation |
| `src/analyzers/component-similarity.js` | 491 | Weighted similarity algorithm, clustering |
| `src/browser-extractors/` | 669 | Playwright extractors (fonts, CSS vars, icons, sections) |
| `src/exporters/markdown.js` | 526 | LLM-optimized report format |
| `src/core/design-system-generator.js` | 104 | Aggregation from page results → unified system |
| `src/mcp-server.js` | 1,041 | MCP tool schemas, handler patterns, error handling |

### Agent Designs to Adapt:

| Agent | Lines | Adaptation for Petal |
|-------|-------|---------------------|
| `color-system-designer` | 1,635 | → Brand color system builder (add brand.json output) |
| `component-designer` | 1,893 | → Brand-aware component recommender |
| `color-auditor` | 1,443 | → Brand compliance auditor (expand beyond colors) |
| `design-system-guardian` | 991 | → Brand enforcement hook (add voice/tone checks) |
| `design-system-doctor` | 1,137 | → Brand health diagnostics |

### Patterns to Copy Exactly:

- **Ecosystem awareness** — shared context injected into agents, sync script
- **LLM constraints document** — compact, structured, injectable
- **Smart analysis decision tree** — quick vs deep, context-aware
- **Progressive enforcement** — strict/new, flexible/legacy, permissive/proto
- **Multi-format export** — JSON + Markdown + organized directory
- **Pre-tool-use hook** — auto-activate enforcement on relevant changes

---

## Key Numbers

| Metric | Count |
|--------|-------|
| Total lines | ~31,000 |
| Agent definitions | 9,381 lines |
| JS source code | ~7,000 lines |
| MCP tools | 6 |
| Specialized agents | 7 |
| Analyzer modules | 10 |
| Browser extractors | 6 |
| Export formats | 3 |
| Version | 3.1.0 |
| Agent guiding principles | 10-12 per agent |

---

## Verdict

Desygnr is a **substantial, production-tested foundation** for petal. It solves the hardest part — the extraction pipeline (Playwright → analyzers → design system JSON → exports) — with real-world battle scars (the changelog documents fixes for 494KB output, over-abstraction, agent discoverability, rainbow mess detection, Tailwind version awareness).

Petal should **fork desygnr's extraction core and agent designs as a starting point**, then layer on:
1. Brand file format (brand.json / brand.md)
2. Voice/tone engine
3. Code audit pipeline (beyond regex to AST)
4. Multi-brand support
5. CI/GitHub Action integration
6. Semantic brand search
7. Wider design token export (W3C DTCG, Figma variables)
