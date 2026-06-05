# Agent Instruction Files — Complete Research

**Date:** June 3, 2026

---

## 1. The DESIGN.md Standard (Google Stitch, Apache 2.0)

Open-sourced April 21, 2026 at `github.com/google-labs-code/design.md`. Defines 9 standard sections:

1. Visual Theme & Atmosphere
2. Color Palette & Roles
3. Typography Rules
4. Component Stylings
5. Layout Principles
6. Depth & Elevation
7. Do's and Don'ts
8. Responsive Behavior
9. **Agent Prompt Guide** (instructions written FOR the agent about how to use the spec)

**Tools:**
- `npx @google/design.md lint` — validates against schema, WCAG contrast, token resolution
- `npx @google/design.md diff` — regression detection between versions
- `npx @google/design.md export --format tailwind` — convert to Tailwind or DTCG tokens

**Adoption:** 68+ brands curated in `VoltAgent/awesome-design-md` (35,000 stars). Real production use at Langflow, Stripe, Vercel, Linear, Notion, and more.

---

## 2. Three-Layer Split (Converging Standard)

| Layer | File | Purpose |
|-------|------|---------|
| **Behavior** | `AGENTS.md` / `CLAUDE.md` | Roles, prohibitions, coding conventions |
| **Tasks** | `SKILL.md` | Reusable procedures, domain expertise |
| **Appearance** | `DESIGN.md` | Design tokens — colors, typography, spacing |

These are NOT competitors — they are layers in a **Business-to-Agent (B2A) stack**.

---

## 3. CLAUDE.md vs AGENTS.md — Priority and Load Order

### Claude Code Load Order (lowest → highest priority)

| Priority | Path | Scope |
|----------|------|-------|
| 1 | `/etc/claude-code/CLAUDE.md` | Org-wide (managed) |
| 2 | `~/.claude/CLAUDE.md` | User global |
| 3 | `~/.claude/rules/*.md` | Modular user rules |
| 4 | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Project (committed) |
| 5 | `./.claude/rules/*.md` | Modular project rules |
| 6 | `./CLAUDE.local.md` | Personal (gitignored) |
| 7 | `./src/CLAUDE.md`, `./packages/*/CLAUDE.md` | Subdirectory, loaded on demand |

AGENTS.md is a **fallback** in Claude Code — if no CLAUDE.md exists, it reads AGENTS.md.

### Cross-Tool Reality

AGENTS.md is now the **Linux Foundation standard** (donated Dec 2025, same foundation as MCP). Read natively by 20+ tools. 60,000+ public repos use it.

**Recommended default for Petal:** AGENTS.md as canonical, CLAUDE.md as symlink or `@import`.

---

## 4. How Reference Files Point to Each Other

### Pattern 1: `@import` (Claude Code)
```markdown
@.claude/standards/api.md
```
Up to 5 levels of recursive import.

### Pattern 2: Explicit reference
```markdown
## Design System
Always refer to DESIGN.md when generating UI.
Use only colors, fonts, and spacing defined there.
```

### Pattern 3: Auto-generation from canonical source
BrandKit MCP and brandmd both generate tool-specific files (CLAUDE.md, AGENTS.md, .cursorrules) from a single DESIGN.md source. Uses delimiter markers (`<!-- BRANDKIT:START -->` / `<!-- BRANDKIT:END -->`) to prevent conflicts.

### Pattern 4: Symlinking
```bash
ln -s AGENTS.md CLAUDE.md  # AGENTS.md is canonical
```

---

## 5. Agent Skills Specification (agentskills.io)

Open standard published Dec 2025, `github.com/agentskills/agentskills`. Supported by 26+ platforms.

### Directory Structure
```
skill-name/
├── SKILL.md          # YAML frontmatter + Markdown body
├── scripts/          # Executable code
├── references/       # Loaded on demand
├── assets/           # Templates, images
└── forms/            # Structured form definitions
```

### Progressive Disclosure (Three Tiers)

| Tier | Content | Token Cost |
|------|---------|------------|
| L1 (Discovery) | `name` + `description` only | ~100 tokens/skill |
| L2 (Activation) | Full SKILL.md body | <5,000 tokens |
| L3 (Execution) | scripts/, references/, assets/ | On demand |

**Installing 20 skills costs ~2,000 tokens at startup — ~90% less than monolithic prompts.**

### Triggering Mechanism
Model-driven, not keyword-matching. The `description` field carries the entire activation burden. Best practice: "Use this skill when..." with rich trigger keywords.

---

## 6. Public Brand Skills Found

| Skill | Source | Notable |
|-------|--------|---------|
| **Netresearch Branding** | `github.com/netresearch/netresearch-branding-skill` | MIT. v2.8.0. Separates references/ from SKILL.md. Has scripts, templates, evals. WCAG AA mandatory. |
| **Anthropic "Applying Brand Guidelines"** | `github.com/anthropics/claude-cookbooks` | Template skill with Acme Corp example. Shows recommended pattern. |
| **Resend Design Skills** | agentskills.so | Resend's brand design system as a skill |
| **Mastra Brand Guidelines** | lobehub.com | Part of Mastra framework. Three tools: `skill`, `skill_read`, `skill_search`. |
| Various others | muapi-brand-kit, brand-guide, brand-identity, brand-persona-skill, style-guide-generator, brand-voice-consistency | Community skills of varying quality |

---

## 7. Context Budget Best Practices

| File | Target Size |
|------|-------------|
| Root AGENTS.md / CLAUDE.md | **<100-200 lines** |
| Domain/skill guides | **<300 lines** each |
| Per-file token budget | **<2,000-2,500 tokens** |

**Key rules:**
- Only encode what agents CANNOT discover from config files
- Write constraints, not descriptions: "always X", "never Y", "when X then Y"
- Tables over paragraphs, bullets over sentences
- Add rules post-hoc (only after an agent gets it wrong)
- 2-3 focused files outperform one comprehensive file by +18.8 percentage points

---

## 8. How MCP Tools Avoid Duplication

| Pattern | Tool | Mechanism |
|---------|------|-----------|
| Delimiter markers | BrandKit | `<!-- BRANDKIT:START/END -->` |
| Single-call loading | Markdown Rules MCP | `get_relevant_docs` once per session |
| URI-based addressing | BrandKit, Synapse | `brandkit://`, `synapse://` |
| Auto-generation from canonical source | BrandKit, brandmd | One source → multiple tool-specific files |

**Core risk:** Brand info duplicated across CLAUDE.md, SKILL.md, MCP tools, and DESIGN.md inevitably drifts. **Mitigation:** auto-generate tool-specific files from one canonical source.

---

## 9. llms.txt — Relevant But Different Purpose

llms.txt is to the **web surface** of a brand what DESIGN.md is to the **visual implementation** and AGENTS.md is to the **development process**. They are complementary layers in a B2A stack — not competitors.

- `/llms.txt` — curated site index for AI crawlers (Jeremy Howard / Answer.AI, Sept 2024)
- `/llms-full.txt` — full content of linked pages in one file
- `/brand.txt` — emerging companion for brand identity in <200 words
- Not directly relevant to Petal's coding-agent focus, but good to know exists

---

## Implications for Petal

1. **Petal should output DESIGN.md** — it's the emerging standard, Apache 2.0, Google-backed, 35K stars. Dovetails with DTCG tokens.

2. **Petal IS a Skill** — `SKILL.md` with progressive disclosure. Name + description at L1, brand extraction logic at L2, reference files at L3.

3. **Petal writes to AGENTS.md** — add a breadcrumb line: "Brand: see DESIGN.md. Run /petal check before committing UI/copy." Minimal context cost.

4. **One canonical source** — Petal reads the user's brand assets and outputs `.brand/DESIGN.md` as the canonical truth. AGENTS.md and MCP tools (later) reference it — they never duplicate it.

5. **Netresearch skill is the best reference** — download it, study the structure. It separates references/ from SKILL.md, includes scripts for automation, and tracks examples.
