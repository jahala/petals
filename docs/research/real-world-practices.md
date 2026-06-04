# Real-World Practices: Brand for Agents, Design Linting, Typography

**Date:** June 3, 2026

---

## Part 1: What Real Teams Actually Do Today for "Brand for Agents"

### The Three-Layer Architecture (Converging Standard)

The AI instruction space is converging on a **three-layer split** for brand-to-agent communication:

| Layer | File | Purpose |
|---|---|---|
| **Behavior** | `CLAUDE.md` / `AGENTS.md` / `.cursorrules` | Roles, prohibitions, coding conventions (e.g., "Never hardcode colors") |
| **Tasks** | `SKILL.md` (Anthropic Agent Skills spec) | Reusable, specific task procedures (brand voice, Figma-to-code) |
| **Appearance** | `DESIGN.md` (Google Stitch spec, Apache 2.0) | Machine + human-readable design tokens: colors, typography, spacing |

Key article: "[AGENTS.md, SKILL.md, DESIGN.md: How AI Instructions Split into Three Layers](https://dev.to/aws-builders/agentsmd-skillmd-designmd-how-ai-instructions-split-into-three-layers-d0g)" — emerging consensus.

### How Companies Actually Do It Today

**1. The Simplest: Copy-Paste Brand Guidelines into CLAUDE.md**
Many teams just paste their brand guidelines (colors, fonts, spacing) into their project's `CLAUDE.md`. Works for small teams but doesn't scale — context window gets clogged, every project duplicates the same brand info.

**2. DESIGN.md by Google Stitch (Open Source, Apache 2.0)**
The draft spec with 9 standard sections: Visual Theme, Color Palette & Roles, Typography Rules, Component Stylings, Layout Principles, Depth & Elevation, Do's and Don'ts, Responsive Behavior, and an **Agent Prompt Guide** (explicitly a prompt for the agent about how to use the spec). Ships with `npx @google/design.md lint` for validation. Drop in project root and reference from `CLAUDE.md`. Works with Claude Code, Cursor, Copilot, Codex, Gemini CLI.

**3. Claude "Skills" (Anthropic, October 2025)**
Skills are folders with instructions, scripts, and resources that Claude discovers and loads dynamically. Uses progressive disclosure (metadata first, full instructions only when relevant). Works across Claude app, Claude Code, API, and Agent SDK.

**Real results:**
- **Rakuten**: Finance workflows — 8x productivity improvement
- **Box**: Stored files into on-brand docs — hours saved per workflow
- **Canva**: Consistent branded designs via Skills integration

**4. BrandKit MCP (Open Source)**
MCP server exposing entire design system to AI tools. Drop in CSS files, Markdown, PDFs, SVGs, fonts — zero-config ingestion. 12 tools, 16+ resources, 4 prompts. Auto-generates `CLAUDE.md`, `AGENTS.md`, `SKILLS.md`, and `DESIGN.md`. Key innovation: a human-authored "taste primer" (`magic_trick.md`) that gives AI brand instincts, not just specs.

**5. Agency Workflow: brandmd + DESIGN.md**
`npx brandmd <url>` extracts any website's design system into `DESIGN.md` automatically. The `--agent` flag writes `.cursor/rules/brand.mdc` + `.claude/skills/`. Supports `--vision`, `--dark`, `--tailwind`, `--css`, `--json` flags.

**6. Anthropic's Reference Brand Voice Skill**
GitHub: `anthropics/knowledge-work-plugins/partner-built/brand-voice/skills/brand-voice-enforcement/SKILL.md` — reference implementation showing how to structure brand-voice enforcement as portable Agent Skills.

**7. cursor2claude — Cross-IDE Brand Sync**
Syncs Cursor `.mdc` rules into `CLAUDE.md`. Write a rule once, both AIs follow it. `npx cursor2claude sync` or `npx cursor2claude watch`.

### Major Enterprise Case Studies

| Company | Approach | Result |
|---|---|---|
| **Coca-Cola × Adobe "Project Fizzion"** | StyleIDs — machine-readable codes encoding brand rules into assets. Instant campaign reformatting across 200+ countries. | AI follows creative intent, human leads |
| **Hershey's** | Converts 400-page brand guideline PDFs into machine-readable Style IDs. Every asset carries embedded brand rules; off-brand flagged instantly. | Scout → Test → Scale → Learn |
| **Newell Brands × Adobe Firefly** | Firefly Custom Models trained on brand assets. | 5x faster campaign production |
| **Superside** | Used own AI platform to self-rebrand. Custom AI image model + internal GPT for brand voice. | 10x faster image creation, 75% less time per image, 85% lower cost |
| **Deutsche Telekom "Magenta AI"** | Integrated multiple AI services into existing apps, maintaining brand consistency through design system-aligned typography, color, iconography. | Standardized output across heterogeneous AI tools |
| **Jasper × Braze** | Jasper IQ enforces brand/style guidelines as guardrails. Embedded governed AI content generation into Braze's marketing platform. | Brand-safe content at scale |

### Common Pattern Across All

1. **Encode brand rules in machine-readable format** (DESIGN.md, SKILL.md, or MCP tools)
2. **Auto-inject at generation time** (AI reads brand spec before generating UI or copy)
3. **Validate post-generation** (CI checks, linters, automated audits flag deviations)
4. **Human-in-the-loop for approval** (AI accelerates, humans lead)

---

## Part 2: Design Token Validators — State of the Art

### Production-Grade Tools

| Tool | Best For | Autofix | CI-Ready | License |
|---|---|---|---|---|
| `stylelint-design-token-guard` | Full token enforcement with JSON config | Yes | Yes | Open source |
| `stylelint-declaration-strict-value` | Whitelist-only per-property enforcement | Limited | Yes | MIT |
| Mozilla `use-design-tokens` | Per-property flexible enforcement | No | Yes | Mozilla |
| `@navikt/aksel-stylelint` | Token existence + scope enforcement | No | Yes | MIT |
| `@wordpress/stylelint-config` | Token existence + reassignment checks | No | Yes | GPL |
| `@atlaskit/stylelint-design-system` | Category toggles (color/spacing/typo) | No | Yes | Atlassian |
| `@google/design.md` CLI | Full CLI: lint, diff, export, WCAG | No | Yes | Apache 2.0 |
| ESLint `no-hardcoded-colors` | Tailwind/JSX enforcement | No | Yes | Project-specific |

**`stylelint-design-token-guard`** is the most comprehensive — detects hex, rgb/rgba, hsl/hsla, and transparent. Autofix replaces exact matches with `var(--token-name)`. Close match warnings for numeric `px` values near a token.

**`@google/design.md` CLI**: `lint` validates broken references + WCAG contrast (4.5:1 minimum). `diff` detects token-level changes with regression flags for CI. `export` converts tokens to Tailwind or W3C DTCG format. 7 built-in linting rules.

### Recommended CI Pattern

1. **Tokens defined in files**: `colors.css`, `spacing.css`, `typography.css`, `breakpoints.css`
2. **Custom validator**: stylelint config with token enforcement rules
3. **CI integration**: Husky pre-commit hooks + CI workflow
4. **Rollout strategy**: "warning" mode initially → graduated to "error" after migration

---

## Part 3: Font Stack and Web Typography Best Practices

### How Agents Receive Font Specifications (Four Tiers)

| Tier | Content | Example |
|------|---------|---------|
| 1. Minimal | Font family name only | `"Inter"` — agent is expected to know how to use it |
| 2. Full font stack | Family name + system fallbacks | `"Inter", -apple-system, sans-serif` |
| 3. Complete CSS block | `@font-face` with `src`, `font-weight` range, `font-display`, `unicode-range` | Full CSS for agent to copy |
| 4. DTCG tokens | Machine-readable typography tokens with all properties | `fontFamily` array, `fontSize`, `fontWeight`, `lineHeight`, `letterSpacing` |

**For Petal:** supporting tiers 2-4 provides comprehensive font guidance. Tier 1 is insufficient for reliable AI generation.

### Variable Fonts (2025: Universal Browser Support)

```css
@font-face {
  font-family: "Inter Variable";
  src: url("/fonts/inter-variable.woff2") format("woff2-variations");
  font-weight: 100 900;
  font-stretch: 75% 125%;
  font-display: swap;
}
```

Five registered axes: Weight (`wght`), Width (`wdth`), Italic (`ital`), Slant (`slnt`), Optical Size (`opsz`). When to use variable vs static: 3+ weights/styles needed → variable (one file). Only 2 weights → static (usually smaller).

### Font Loading Strategy

| `font-display` Value | Behavior | Best For |
|---|---|---|
| `swap` | Show fallback immediately, swap when ready | Body text (recommended) |
| `fallback` | Brief invisible period (~100ms), then fallback | Semi-critical text |
| `optional` | Use only if cached; never swap | Decorative fonts |
| `block` | Hide text up to 3s | Avoid |

### Performance Budget

- First-screen fonts: max 200KB total
- Number of typefaces: 2-3 maximum (body + display + monospace)
- Font weights loaded: 4-5 max
- WOFF2 only in 2025 (30% better compression)

---

## Key Implications for Petal

1. **Market converging around three files**: `CLAUDE.md` (behavior), `SKILL.md` (tasks), `DESIGN.md` (appearance). Petal should support all three.

2. **Design token enforcement in CI is solved at the tool level** (Stylelint, ESLint). Petal's value: providing the canonical brand data that these tools validate against.

3. **Font specification for agents needs to go beyond just a name**. The four tiers represent a maturity curve. Petal should output at the highest tier the agent supports.

4. **No dominant open-source brand MCP server exists** — competitors each cover a slice. Petal can be the comprehensive open-source option bridging extraction, encoding, distribution, and enforcement.

5. **The human-authored "taste primer"** from BrandKit MCP (`magic_trick.md`) is notable: gives AI brand instinct, not just specifications.
