# Petal — PRD, Design & Architecture

**Version:** 0.1.0 — Draft
**Date:** 2026-06-03
**Status:** Research complete. Architecture specified. Ready for tend feature breakdown.

---

## Table of Contents

1. [Vision](#1-vision)
2. [What Petal Is](#2-what-petal-is)
3. [What Petal Is Not](#3-what-petal-is-not)
4. [The Brand File Format](#4-the-brand-file-format)
5. [Architecture](#5-architecture)
6. [The /petal Skill](#6-the-petal-skill)
7. [How Agents Discover & Use Petal](#7-how-agents-discover--use-petal)
8. [Composability With Other Skills](#8-composability-with-other-skills)
9. [Distribution Model](#9-distribution-model)
10. [Future: MCP Server](#10-future-mcp-server)
11. [Competitive Positioning](#11-competitive-positioning)
12. [Implementation Phases](#12-implementation-phases)
13. [Open Questions](#13-open-questions)

---

## 1. Vision

**Every AI agent that touches a company's brand — whether it's writing copy, building UI, generating assets, or reviewing work — has instant, confident access to the canonical brand truth. No copy-pasting guidelines. No guessing colors. No brand drift across projects.**

Petal makes a company's brand machine-readable, agent-callable, version-controlled, and self-hosted. It's the brand infrastructure layer for the agent era.

---

## 2. What Petal Is

### 2.1 In One Sentence

**Petal is a Claude Code skill that reads a folder of brand assets, creates a structured `.brand/` directory of agent-readable files, and provides commands for agents to check their work against brand rules.**

### 2.2 Core Components

| Component | What It Does |
|-----------|-------------|
| `/petal init <folder>` | Points at a folder of brand assets. LLM reads everything (PDFs, images, markdown, JSON, CSS). Produces `.brand/` directory with structured, agent-readable files. |
| `.brand/` directory | The output. A set of markdown files + asset copies that any agent can read directly. No database. No API. Just files. |
| `/petal check [file]` | Audits a file (code, copy, UI) against the brand rules in `.brand/`. Reports compliance. |
| `/petal voice <text>` | Checks copy against brand voice rules. Returns score + suggestions. |
| `/petal color <name>` | Looks up and returns a specific brand color. |
| `/petal update` | Fetches the latest `.brand/` from the central brand repo. |
| `AGENTS.md` breadcrumb | A single line in the project's AGENTS.md: "Brand: see DESIGN.md. Use /petal check before committing UI/copy." |

### 2.3 The `.brand/` Directory

```
.brand/
├── DESIGN.md               # Canonical brand design system (Google Stitch format)
│                           # 9 sections: Visual Theme, Colors, Typography,
│                           # Components, Layout, Depth, Do's/Don'ts,
│                           # Responsive Behavior, Agent Prompt Guide
│
├── identity.md             # Brand name, tagline, mission, story, positioning
│
├── colors.md               # Detailed color reference
│                           # Hex, RGB, CMYK, OKLCH per color
│                           # Semantic roles (primary, accent, error, etc.)
│                           # Light/dark mode variants
│                           # WCAG contrast ratios
│                           # Approved + forbidden combinations
│                           # CSS custom properties
│
├── typography.md           # Font families, weights, scale, pairings
│                           # @font-face declarations (Tier 3)
│                           # Fallback stacks
│                           # Responsive scale
│
├── voice.md                # Brand voice and tone
│                           # Personality traits
│                           # Vocabulary (approved terms, forbidden terms)
│                           # Grammar and formatting rules
│                           # Before/after examples
│                           # Context-specific adaptations
│
├── imagery.md              # Photography style, illustration style
│                           # Do's and don'ts with examples
│
├── components.md           # UI component catalog (optional)
│                           # Available components with variants
│                           # Usage guidelines per component
│
├── tokens.json             # W3C DTCG design tokens
│                           # Machine-readable, standards-compliant
│                           # For tools that consume DTCG format
│
├── brand.json              # Machine-readable brand summary
│                           # For MCP server (future) and programmatic access
│
├── assets/                 # Hard copies of brand assets
│   ├── logo-primary.svg
│   ├── logo-dark.svg
│   ├── logo-mark.svg
│   ├── favicon.png
│   └── ...
│
└── overrides.yaml          # Project-specific overrides (gitignored)
                            # null = inherit from central
                            # Override specific values for campaign sites, etc.
```

### 2.4 The User Experience

```
# First time: create brand from assets
$ /petal init ./brand-assets/
Petal: Reading brand-assets/...
       Found: brand-guide.pdf (40 pages), logo-primary.svg, logo-dark.svg,
              color-palette.json, imagery-moodboard/
       
       Extracting brand identity...
       ✓ Colors: 8 colors found (primary: #2F99A4, accent: #FF4D00, ...)
       ✓ Typography: Raleway (headings), Open Sans (body)
       ✓ Voice: Direct, warm, technical but approachable
       ✓ Logos: 2 variants (primary, dark)
       
       Created .brand/ with 10 files.
       
       Next: Commit .brand/ to your central brand repo.
             In projects, run /petal init --from github.com/company/brand

# In a project: pull brand from central
$ /petal init --from github.com/company/brand
Petal: Fetching brand from github.com/company/brand (v1.3.0)...
       Created .brand/ with 10 files.
       Added breadcrumb to AGENTS.md.

# Agent building UI reads context passively
Agent: [reads .brand/DESIGN.md before generating UI]
       → Uses --nr-primary for CTAs
       → Uses Raleway for headings
       → Matches spacing scale

# Agent checks work at natural boundaries
Agent: /petal check landing-page.tsx
Petal: ✅ Colors: All 12 color values in palette
       ✅ Typography: Headings use Raleway, body uses Open Sans
       ⚠️  Line 42: spacing 13px outside scale (closest: 12px or 16px)
       ⚠️  Line 87: hardcoded #3B82F6 not in palette (closest: primary #2F99A4)
       
       2 warnings. 0 errors.

# Agent checks copy
Agent: /petal voice "We leverage AI to synergize your workflow"
Petal: ⚠️  "leverage" is on the forbidden terms list → use "use"
       ⚠️  "synergize" is jargon → rephrase for clarity
       Suggested: "We use AI to speed up your workflow"
```

---

## 3. What Petal Is Not

| Not Petal's Job | Why |
|-----------------|-----|
| **AI image generation** | Commodity. Every AI platform does this. Petal provides the brand context FOR generators. |
| **Video generation** | Outside scope. Brand intelligence, not media generation. |
| **Real-time brand firewall** | Petal is checkpoints, not continuous enforcement. Agents are smart enough to follow rules when they know them. |
| **SaaS platform** | Petal is files in a repo. Self-hosted by definition. No login, no billing, no database. |
| **Figma plugin** | Petal reads Figma exports. Doesn't need a plugin. |
| **Credit/pricing system** | Files are free. |
| **Complex extraction algorithms** | LLMs with vision read PDFs, analyze images, and understand design better than any hand-written parser. Petal delegates extraction to the agent's native capabilities. |
| **7 specialized agents** | One skill, one job. Desygnr proved that 7 agents work for analysis. Petal is simpler: one skill with clear subcommands. |
| **Playwright/browser automation (v1)** | Heavy. LLMs read files directly. If extraction needs browser rendering, the agent can use existing MCP tools. |
| **Font licensing enforcement** | The user's responsibility. Petal catalogs fonts; doesn't police licensing. |
| **Push notifications for brand updates** | Next time an agent works, it notices the drift. Git is the notification system. |

---

## 4. The Brand File Format

### 4.1 DESIGN.md — Canonical Design System

Petal's primary output format is **DESIGN.md**, the Google Stitch open standard (Apache 2.0, `github.com/google-labs-code/design.md`). It was chosen because:

- **Apache 2.0 license** — no restrictions on use
- **35,000+ GitHub stars** — rapidly becoming the standard
- **9 standardized sections** — clear structure that agents understand
- **Agent Prompt Guide** — section 9 is explicitly written FOR agents
- **CLI tooling** — `npx @google/design.md lint` for validation, `diff` for changes, `export` for Tailwind/DTCG
- **68+ brands already published** in `VoltAgent/awesome-design-md`

The 9 DESIGN.md sections:

1. **Visual Theme & Atmosphere** — overall aesthetic, mood, design philosophy
2. **Color Palette & Roles** — semantic color names with hex + functional roles
3. **Typography Rules** — font families, hierarchy table with sizes/weights
4. **Component Stylings** — buttons, cards, inputs with states
5. **Layout Principles** — spacing scale, grid, whitespace rhythm
6. **Depth & Elevation** — shadow tokens, surface hierarchy
7. **Do's and Don'ts** — guardrails and anti-patterns for agents
8. **Responsive Behavior** — breakpoints, touch targets
9. **Agent Prompt Guide** — instructions for the AI reading the file

### 4.2 Supporting Files Beyond DESIGN.md

DESIGN.md covers the visual design system. Petal adds files for things DESIGN.md doesn't cover:

| File | Covers | Why DESIGN.md Doesn't |
|------|--------|----------------------|
| `identity.md` | Brand story, mission, positioning, tagline | DESIGN.md is visual; identity is verbal/strategic |
| `voice.md` | Tone, vocabulary, grammar rules, before/after examples | DESIGN.md is visual; voice is linguistic |
| `imagery.md` | Photography style, illustration guidelines | DESIGN.md has Visual Theme but not detailed imagery specs |
| `components.md` | Component catalog with usage rules | DESIGN.md has "Component Stylings" but petal's version goes deeper with anti-patterns |
| `tokens.json` | W3C DTCG machine-readable tokens | DTCG is for tool consumption; DESIGN.md is for human+agent reading |
| `brand.json` | Machine-readable summary for MCP/programmatic access | Future use; DTCG covers tokens but not brand identity fields |

### 4.3 File Format Philosophy

- **Markdown is the primary format** — human-readable AND agent-readable. Any agent can read markdown natively.
- **JSON for machine consumption** — DTCG tokens for design tools, brand.json for MCP.
- **Explicit over inferred** — hex values are always stated explicitly. Fonts are specified with full CSS. No "the brand feels warm" without also "primary color: #E7000B."
- **Hard rules alongside soft guidance** — "Primary color is #2F99A4" (hard) + "Use sparingly, ~10% of UI" (soft). Both are valuable. Agents need both.
- **Copy-paste ready** — CSS custom properties, @font-face declarations, Tailwind config snippets are included verbatim. Agents can use them immediately.

---

## 5. Architecture

### 5.1 The Stack (What Runs Where)

```
┌─────────────────────────────────────────────────────┐
│ CENTRAL BRAND REPO                                  │
│ github.com/company/brand (git)                       │
│                                                     │
│ .brand/                   ← Brand team edits these  │
│ Versioned with git tags   ← v1.0.0, v1.1.0, ...    │
└────────────────────┬────────────────────────────────┘
                     │
                     │  HTTPS fetch or git clone --depth 1
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   Project A    Project B    Project C
   .brand/      .brand/      .brand/
   (cache,      (cache,      (cache,
   gitignored)  gitignored)  gitignored)
   .petalrc     .petalrc     .petalrc
```

### 5.2 The Flow

```
1. USER creates central brand repo
   /petal init ./brand-assets/ → outputs .brand/
   User pushes .brand/ to github.com/company/brand
   User tags v1.0.0

2. PROJECT pulls brand from central
   /petal init --from github.com/company/brand
   → Fetches .brand/ via HTTPS or shallow clone
   → Creates .petalrc with source URL
   → Adds AGENTS.md breadcrumb

3. AGENT works with brand context
   → Reads .brand/DESIGN.md before generating UI
   → Reads .brand/voice.md before writing copy
   → Uses .brand/assets/logo.svg for headers

4. AGENT checks work at boundaries
   /petal check → validates against .brand/
   /petal voice → checks tone compliance

5. BRAND UPDATES
   Brand team edits central repo, tags v1.1.0
   Nothing happens immediately. No push, no webhook.

6. AGENT detects drift (next time they work)
   /petal check → "⚠️ Brand behind (v1.0.0 → v1.1.0). Primary color changed."
   /petal update → fetches latest
```

### 5.3 Why No Server

- **Files are the universal API.** Any agent, any language, any tool can read markdown and JSON.
- **Git is the distribution layer.** Already authenticated. Already versioned. Already understood by every developer.
- **LLMs read files natively.** No MCP tool needed for "what's our primary color?" — just read `.brand/colors.md`.
- **Zero infrastructure.** No deployment. No uptime. No auth server. No database. No cost.
- **An MCP server comes later** — for programmatic queries, non-Claude agents, and CI pipelines. But it's additive, not foundational.

### 5.4 Project Overrides

Some projects legitimately diverge. A campaign microsite might use a seasonal palette. A docs site might have stricter typography.

```yaml
# .petalrc
brand:
  source: github.com/company/brand
  version: v1.3.0
  overrides:
    colors:
      primary: "#SEASONAL-HEX"
    typography:
      body: "CustomFont"  # narrower for docs
```

Resolution: overrides win where set. `null` = fall through to central. Central updates still flow through for everything not overridden. 95% of values come from central; projects customize 1-2 things without forking the brand.

---

## 6. The /petal Skill

### 6.1 Structure

```
petal/
├── SKILL.md                  # ~100 lines. L2 activation body.
│                             # Auto-trigger conditions
│                             # Subcommands: init, check, voice, color, update
│                             # Hard validity rules
│                             # Reference workflow
│
├── references/               # Loaded on demand (L3)
│   ├── extraction-guide.md   # How to read brand assets with LLMs
│   ├── DESIGN.md.template    # Template for generated DESIGN.md
│   ├── voice-guide.md        # How to audit copy against voice rules
│   └── color-audit-guide.md  # How to check hardcoded colors
│
├── templates/                # Output templates
│   ├── DESIGN.md             # Skeleton DESIGN.md with all 9 sections
│   ├── identity.md           # Identity template
│   ├── colors.md             # Color reference template
│   ├── typography.md         # Typography reference template
│   └── voice.md              # Voice/tone template
│
└── scripts/                  # Deterministic operations
    └── fetch-brand.sh         # Clone/fetch brand from central repo
```

### 6.2 SKILL.md Frontmatter

```yaml
---
name: petal
description: >
  Use this skill when working with ANY brand-related output: UI components,
  landing pages, marketing copy, design assets, or visual content. Also use
  when the user mentions brand compliance, design system, brand colors,
  typography, brand voice, or asks to check if something is "on-brand."
  This skill provides brand context, validates work against brand rules,
  and ensures consistency across all agent-generated output.
license: MIT
metadata:
  version: "0.1.0"
---
```

### 6.3 Subcommands

| Command | What It Does | When Agent Calls It |
|---------|-------------|-------------------|
| `init <folder>` | Create `.brand/` from brand assets | Setting up a new central brand repo |
| `init --from <url>` | Pull `.brand/` from central repo | Joining a project that has a brand |
| `check [file]` | Audit file against `.brand/` rules | After generating UI/copy, before committing |
| `voice <text>` | Check copy against voice rules | After writing headlines, taglines, body copy |
| `color <name>` | Look up and return a brand color | During UI work when unsure about a color |
| `token <format>` | Export design tokens (CSS, Tailwind, DTCG) | When setting up a new project or component |
| `update` | Fetch latest `.brand/` from central | When petal warns brand is behind |
| `logo [variant]` | Return path/instructions for logo usage | When adding logo to UI |

### 6.4 Auto-Trigger Conditions

Petal should auto-activate when:
- Agent is creating or modifying UI components (HTML, JSX, TSX, Vue, Svelte, CSS)
- Agent is writing marketing copy, landing page text, or user-facing content
- Agent mentions branding terms (logo, style guide, brand colors, typography)
- Another skill generates user-facing visual or textual content
- `.brand/` directory exists in the project
- The project's AGENTS.md references petal

### 6.5 Hard Validity Rules

When petal is active, these are non-negotiable:

1. Colors must come from `.brand/colors.md` palette. No hardcoded hex values outside the palette.
2. Typography must follow `.brand/typography.md` hierarchy. Headings use heading font; body uses body font.
3. Logos must use assets from `.brand/assets/`. No substitutions, no recoloring, no distortion.
4. Voice must follow `.brand/voice.md` rules. Forbidden terms detected → flag and suggest alternative.
5. If user instructions conflict with brand rules, petal explains the constraint and asks.

---

## 7. How Agents Discover & Use Petal

### 7.1 The Three-Layer B2A Stack

Petal participates in the industry-standard three-layer agent instruction model:

```
Layer 1: AGENTS.md     →  "Brand: see DESIGN.md. Use /petal check."
                          (~1 line. Behavior + pointer.)
Layer 2: SKILL.md      →  /petal skill. Auto-activates on brand-relevant work.
                          (~100 lines. Tasks + procedures.)
Layer 3: DESIGN.md     →  The canonical brand design system.
                          (Full spec. Appearance.)
```

### 7.2 Passive Context (No Action Needed)

When an agent starts work on a project with `.brand/`, the AGENTS.md breadcrumb tells it brand files exist. The agent reads the relevant files naturally as part of its workflow — just like it reads `README.md` or `package.json`.

### 7.3 Active Checks (Explicit Action)

At natural boundaries in the workflow, the agent calls petal explicitly:

- After writing UI code → `/petal check component.tsx`
- After writing copy → `/petal voice "headline text"`
- When unsure about a color → `/petal color accent`
- Before committing → `/petal check` (full project scan)

### 7.4 Future: PreToolUse Hook (Fully Automatic)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/petal-pre-write.sh"
          }
        ]
      }
    ]
  }
}
```

The hook script checks:
1. Is `.brand/` present?
2. Is the file being written a UI file or copy file?
3. If yes, inject brand context via `additionalContext`
4. After write, run `/petal check` via PostToolUse hook

**This is v2. v1 uses passive context + explicit checks.** Agents are smart enough to follow instructions in AGENTS.md without hooks enforcing it.

### 7.5 Context Budget Discipline

Petal is designed to be extremely cheap in context:

| What | Token Cost |
|------|-----------|
| AGENTS.md breadcrumb | ~15 tokens |
| SKILL.md (L1 discovery, name + description) | ~100 tokens |
| SKILL.md (L2 activation, full body) | ~2,500 tokens (only when petal activates) |
| DESIGN.md (on demand, not always loaded) | Variable (agent reads sections as needed) |
| References (on demand) | Variable (only when checking specific things) |

**Petal adds negligible context cost when idle.** Other skills activate without petal getting in the way. When petal is needed, it loads the right amount of context for the task.

---

## 8. Composability With Other Skills

### 8.1 The Conductor Pattern

Petal doesn't own the workflow. It's called **between** other skills:

```
┌─────────────────────────────────────────┐
│ AGENT TASK: Build landing page hero     │
│                                         │
│ 1. [Reads .brand/ for context]  ← Petal│
│ 2. /copywriter drafts headlines         │
│ 3. /petal voice ← Petal checkpoint      │
│ 4. Copywriter iterates                  │
│ 5. /component-designer builds UI        │
│ 6. /petal check ← Petal checkpoint      │
│ 7. Agent adds logo ← Petal context      │
│ 8. /petal check final ← Petal review   │
└─────────────────────────────────────────┘
```

### 8.2 Composition Rules

1. **Petal provides context before work.** Agent reads `.brand/` files before starting creative work. This is passive — no skill call needed.
2. **Petal checks output after work.** After another skill produces output, petal validates it against brand rules. This is active — `/petal check` or `/petal voice`.
3. **Petal answers questions during work.** When an agent is mid-flow and needs a specific brand value, `/petal color` or `/petal token` returns it immediately.
4. **Petal doesn't block other skills.** If `/copywriter` is mid-draft, petal waits. It reviews the output, not the process.
5. **Petal merges with project overrides.** If a campaign page has a seasonal override, petal checks against the merged rules (central + overrides), not the pure central brand.

### 8.3 Example: Petal + Copywriter + Component Designer

```
Agent: "Build a pricing page for Acme Corp"

1. Agent reads .brand/DESIGN.md (passive context)
   → Colors: primary #2F99A4, accent #FF4D00
   → Typography: Raleway headings, Open Sans body
   → Voice: Direct, technical but approachable

2. Agent calls /copywriter to draft pricing headlines
   → "Simple pricing for complex problems"
   → "Start free. Scale when you're ready."

3. Agent calls /petal voice on the headlines
   → ✅ "Simple pricing for complex problems" — on-voice
   → ⚠️ "Scale when you're ready" — slightly corporate. Suggest "Grow at your own pace"

4. Copywriter iterates with petal feedback

5. Agent calls component-designer for pricing table component
   → Component uses design system tokens
   → Button variants: primary (teal, 10%), secondary (outline, 20%)

6. Agent builds the page

7. Agent calls /petal check pricing.tsx
   → ✅ All colors in palette
   → ✅ Typography hierarchy correct
   → ⚠️ Spacing at line 87: 13px outside 4px scale

8. Agent fixes spacing. /petal check → ✅ Clean.
```

---

## 9. Distribution Model

### 9.1 Central Brand → Projects

```
Central:  github.com/company/brand (git repo with .brand/ directory)
          Tagged versions: v1.0.0, v1.1.0, v1.2.0

Projects: .brand/ is gitignored. Populated by /petal update.
          .petalrc records: source = github.com/company/brand, version = v1.2.0
```

### 9.2 Fetch Mechanism

Petal supports two fetch strategies, automatically selected:

**Strategy 1: HTTPS API fetch** (default)
```bash
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/repos/company/brand/contents/.brand/colors.md \
  | jq -r '.content' | base64 -d > .brand/colors.md
```
Works for both public and private repos. Uses existing `GITHUB_TOKEN` or `GH_TOKEN` from the developer's environment.

**Strategy 2: Shallow clone** (when git + SSH available)
```bash
git clone --depth 1 git@github.com:company/brand.git /tmp/brand-XXXXX
cp -r /tmp/brand-XXXXX/.brand/* .brand/
rm -rf /tmp/brand-XXXXX
```
Faster for full sync. Uses developer's existing SSH keys.

**Selection:**
1. Has `git` and SSH access? → shallow clone
2. Has `GITHUB_TOKEN` env var? → API fetch
3. Public repo? → raw.githubusercontent.com

### 9.3 Version Awareness

```
Agent: /petal check
Petal: ✅ Brand compliance: 0 errors, 2 warnings
       ℹ️  Brand version: v1.2.0 (central is v1.3.0 — 23 days behind)
       Run /petal update to sync.
```

No push, no webhook. Next time the agent works, it notices the drift. Each project updates when it makes sense.

---

## 10. Future: MCP Server

### 10.1 When To Add It

The MCP server comes when:

- Agents need programmatic brand queries at high frequency (not just reading files)
- Non-Claude agents need access (Codex, Gemini, Cursor agents without file system access)
- CI/CD pipelines need brand checks without a full agent session
- Teams want `brand://colors/primary` as a URI rather than reading files

### 10.2 What It Would Look Like

```json
{
  "mcpServers": {
    "petal": {
      "command": "npx",
      "args": ["@petal/mcp-server"]
    }
  }
}
```

**Tools (projected):**
- `brand_get_color(name)` → returns color with hex, rgb, cmyk, contrast ratios
- `brand_get_token(path)` → returns DTCG token by path
- `brand_check_component(code)` → validates component against brand
- `brand_check_copy(text)` → validates copy against voice rules
- `brand_get_asset(name)` → returns path/URL for logo, icon, etc.
- `brand_export(format)` → exports tokens in CSS, Tailwind, DTCG, etc.

**Resources (projected):**
- `brand://colors` → full color palette
- `brand://typography` → full typography system
- `brand://voice` → voice rules
- `brand://assets` → asset catalog

### 10.3 The MCP Server Reads the Same Files

The MCP server doesn't have its own brand data. It reads `.brand/` exactly like the skill does. One canonical source. The MCP server is just a different access method — programmatic instead of file-based.

### 10.4 Auth (When Remote)

Stdio transport (local) → no auth needed. Filesystem only.

HTTP transport (remote, future) → OAuth 2.1 Authorization Code + PKCE S256. This is the MCP specification standard and what everyone else does.

---

## 11. Competitive Positioning

### 11.1 The Market Map

```
                    IMAGE GENERATION FOCUS         BRAND INTELLIGENCE FOCUS
                    ─────────────────────           ────────────────────────
                    
COMMERCIAL          Bloom (YC)                      Design Rails (YC)
                    BrandKity                       The Branx (brand.md)
                    Brandfetch                      Brandsystem/BrandCode
                    Orsa                            brandguide/AI
                                                    Frontify MCP
                                                    zeroheight MCP

OPEN SOURCE         BrandKit MCP                    ★ PETAL ★
                    Dembrandt                       Netresearch Branding Skill
                    OpenBrand                       Mastra Brand Guidelines
                    brandmd
                    tapsite
                    
                    EXTRACTION TOOLS                BRAND GOVERNANCE TOOLS
```

### 11.2 Petal's Position

**Bottom-right quadrant:** Open source brand intelligence + governance. The only tool that:

- Is fully open source (MIT)
- Is self-hostable (file-based, no SaaS)
- Covers the FULL brand spectrum (visual + voice + assets + code)
- Targets coding agents primarily (not image generation)
- Provides extraction AND governance in one tool
- Audits existing code against brand rules
- Uses git for distribution (zero new infrastructure)

### 11.3 Why This Position Wins

No one else is here. The open source extraction tools (Dembrandt, OpenBrand, brandmd) don't do governance. The commercial governance tools (Bloom, Design Rails, The Branx) aren't open source. The enterprise tools (Frontify, zeroheight, Supernova) require SaaS subscriptions.

Petal is the **open source, self-hosted, comprehensive brand intelligence layer for coding agents.** That's a unique position.

---

## 12. Implementation Phases

### Phase 1: Core Skill + Brand Extraction (MVP)

**Deliverable:** `/petal` skill that creates `.brand/` from a folder of assets.

- SKILL.md with init, check, voice, color subcommands
- Templates for all `.brand/` output files
- Extraction guide (references/extraction-guide.md)
- AGENTS.md breadcrumb injection
- Fetch from central repo (`/petal init --from`, `/petal update`)

**Agents can:** Read brand context from files, check their own work.

### Phase 2: Audit & Enforcement

**Deliverable:** `/petal check` is comprehensive.

- Color audit (hardcoded hex detection, palette matching)
- Typography audit (font family, size, weight checks)
- Spacing audit (values outside scale detection)
- Voice audit (forbidden terms, tone analysis)
- Component audit (detect custom components duplicating brand-provided ones)

**Agents can:** Get detailed compliance reports with fix suggestions.

### Phase 3: Export & Integration

**Deliverable:** DTCG tokens, Tailwind config, CSS variables export.

- `/petal token css` → CSS custom properties
- `/petal token tailwind` → Tailwind config
- `/petal token dtcg` → W3C DTCG tokens
- DESIGN.md linter integration (`@google/design.md lint`)
- Stylelint config generation

**Agents can:** Bootstrap new projects with full brand token infrastructure.

### Phase 4: MCP Server

**Deliverable:** `@petal/mcp-server` npm package.

- stdio MCP server (local, no auth)
- All tools and resources from Phase 1-3 exposed as MCP
- Same `.brand/` file reading — no data duplication
- Compatible with Claude Desktop, Claude Code, Cursor, VS Code, etc.

**Any MCP-compatible agent can:** Query brand programmatically.

### Phase 5: CI/CD & Automation

**Deliverable:** GitHub Action, pre-commit hooks.

- `petal-check` GitHub Action for PRs
- Husky pre-commit hook
- Brand drift detection in CI

**CI pipelines can:** Block PRs that introduce brand violations.

---

## 13. Open Questions

1. **Skill distribution:** Should petal be a Claude Code plugin (`/plugin marketplace add`), an npm package (`npx skills add`), or both? Netresearch supports both. Leaning: both.

2. **Brand asset storage:** Large assets (videos, high-res photos) don't belong in git repos. Should `.brand/assets/` use git-lfs? Or fetch from a CDN?

3. **Multi-language brands:** Brands operating in multiple languages need localized voice rules, terminology glossaries, and typography (CJK vs Latin fonts). How does this map to the file structure?

4. **Brand sub-types:** A company might have a corporate brand AND product brands (like Google vs Google Cloud vs Gmail). How does inheritance work across this hierarchy? DTCG has `$extends` for groups. Should petal support brand-level inheritance?

5. **Conflicting skills:** What happens when both petal and another brand skill (e.g., Netresearch's) are installed? Do they compose? Conflict? One takes priority?

6. **Validation vs. generation:** Where's the line between "this color is wrong" (petal's job) and "this layout could be better" (designer's judgment)? Petal should enforce the hard rules and flag the soft ones as suggestions.

---

*This document is the foundation for tend feature planning. Next: `/tend brainstorm` to break this into implementable features.*
