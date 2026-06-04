# Petal — First Principles Design

**What petal is:** A folder you point at your brand assets. It figures out what's there, organizes it into files agents can read, and provides hooks so agents use it at the right time.

---

## 1. The Simplest Thing That Works

```
You:     /petal init ./brand-assets/
Petal:   Reads everything in that folder.
         Creates .brand/ with structured output.
         Done.

Agent:   "Build a landing page hero section"
         → reads .brand/colors.md for palette
         → reads .brand/voice.md for headline tone
         → reads .brand/assets/ for logo
         → builds it on-brand
```

### Input (what you point at)

```
brand-assets/
├── logo-primary.svg
├── logo-dark.svg
├── brand-guide.pdf          # 40-page PDF brand book
├── color-palette.png
├── hero-image.jpg
├── typography-spec.json
└── whatever-else/
```

### Output (what petal creates)

```
.brand/
├── identity.md              # Name, tagline, mission, brand story
├── colors.md                # Palette with hex, OKLCH, usage rules
├── typography.md            # Fonts, scale, pairings
├── voice.md                 # Tone, vocabulary, before/after examples
├── imagery.md               # Photo style, illustration style, do's/don'ts
├── components.md            # UI component patterns (optional)
├── brand.json               # Machine-readable (for MCP later)
├── assets/                  # Hard copies of logos, etc.
│   ├── logo-primary.png
│   ├── logo-dark.png
│   └── ...
└── README.md                # How agents should use this
```

**No database. No backend. No API. Just files in a folder.**

---

## 2. How Extraction Works — Use LLMs Natively

The key insight: **don't build extraction algorithms. LLMs already read PDFs, analyze images, and understand design.** Use what agents do naturally.

### What happens during `petal init`:

| Asset Type | How petal reads it |
|------------|-------------------|
| PDF brand guide | LLM reads the PDF, extracts colors, fonts, voice rules, logo usage |
| Image files (logos, palette swatches) | LLM with vision describes the image, extracts dominant colors |
| CSS / Tailwind config | Parse design tokens directly |
| Font files (.ttf, .woff) | Note their existence, catalog metadata |
| JSON/YAML design tokens | Parse directly |
| Anything else | LLM inspects and decides what's relevant |

The extraction agent's job is to:
1. List everything in the folder
2. Read each file using the best available tool
3. Synthesize findings into the standardized `.brand/` format
4. Flag anything unclear for human confirmation

### This is ~200 lines of skill instructions, not 7,000 lines of JS.

---

## 3. How Agents Use Petal — Three Touch Points

### Touch Point A: Before starting creative work

The agent checks if `.brand/` exists. If yes, it reads the relevant file:

```
Agent task: "Write landing page copy"
→ Agent reads .brand/voice.md
→ Agent reads .brand/identity.md
→ Agent writes copy informed by brand voice
```

This can be automatic via **CLAUDE.md instructions** or a **PreToolUse hook**.

### Touch Point B: During work, when stuck

Agent calls petal explicitly for specific guidance:

```
Agent: /petal color "What's our error state color?"
Petal: Reads .brand/colors.md → returns "--color-error: #DC2626"
```

### Touch Point C: After work, as review

Agent self-checks or a reviewer checks:

```
Agent: /petal check landing-page.tsx
Petal: Scans the file for:
       - Hardcoded colors not in palette
       - Fonts not in typography scale
       - Voice inconsistencies in copy
       → Reports: "✅ Colors on-brand. ⚠️ Line 42 uses #3B82F6 (not in palette — closest match is primary-blue #2563EB)"
```

---

## 4. The Orchestration Problem — When Does Petal Fire?

This is the real question. An agent building a landing page doesn't just do one thing. It:

1. Plans the layout
2. Writes the copy
3. Picks components
4. Applies colors
5. Adds the logo

Where does petal fit?

### Answer: Petal is NOT in the critical path. It's context and checkpoints.

```
┌─────────────────────────────────────────────────┐
│ AGENT WORKFLOW: Build landing page              │
│                                                 │
│ [Before] Read .brand/ for context ← PETAL       │
│    ↓                                            │
│ Plan layout (no petal needed)                   │
│    ↓                                            │
│ Write copy                                       │
│    ↓                                            │
│ /petal voice check ← PETAL REVIEW               │
│    ↓                                            │
│ Build components                                 │
│    ↓                                            │
│ Apply brand colors (reads .brand/colors.md)      │
│    ↓                                            │
│ Add logo (reads .brand/assets/)                  │
│    ↓                                            │
│ /petal check ← PETAL FINAL REVIEW               │
│    ↓                                            │
│ Done                                             │
└─────────────────────────────────────────────────┘
```

Petal is **not a gate**. It's:
- **Context** before work starts (passive — agent reads files)
- **Checkpoints** at natural boundaries (active — `/petal check`)
- **Answering questions** during work (on-demand — `/petal color "..."`)

### How this works with other skills:

If the user has a `/copywriter` skill and a `/petal` skill:

```
User: "Build landing page hero"
Agent: [reads .brand/ for context]
       [uses /copywriter to draft headlines]
       [/petal voice check on the drafts]
       [iterates]
       [uses component-designer for UI structure]
       [/petal check final]
```

Petal composes by being **called between other skills**, not during them. Each skill does its thing, then petal reviews the output against brand.

---

## 5. How to Ensure Petal Gets Used

Three mechanisms, from simplest to most sophisticated:

### Level 1: CLAUDE.md instructions (simplest, always works)

```markdown
## Brand
- When doing ANY creative work (UI, copy, images, landing pages), first check if `.brand/` exists.
- If `.brand/` exists, read the relevant files before starting.
- Before committing creative output, run `/petal check` to verify brand compliance.
```

### Level 2: Skill that auto-injects context

A `/petal` skill that, when called, reads the agent's current task and injects the right `.brand/` files.

### Level 3: PreToolUse hook (most automated)

A hook that detects when the agent is about to write UI code or copy, and injects brand context before the tool executes.

**Recommendation: Start with Level 1 + Level 2. Add Level 3 only if agents consistently forget to check.**

---

## 6. What Petal Does NOT Do

| Not petal's job | Why |
|-----------------|-----|
| AI image generation | Commodity. Every AI does this. Petal provides brand context FOR generators. |
| Video generation | Not brand intelligence. |
| SaaS hosting | Files in repo. Self-hosted by definition. |
| Real-time brand enforcement | Petal is checkpoints, not a firewall. Agents are smart enough to follow rules. |
| Figma plugin | Petal reads from Figma exports, doesn't need a plugin. |
| Credit/pricing system | It's files. Free. |
| Complex color extraction algorithms | LLMs with vision do this better than any algorithm. |
| Playwright/browser automation | Heavy. LLMs read files directly. |
| 7 specialized agents | One skill, one job. Complexity is the enemy. |

---

## 7. Minimum Viable Implementation

```
petal/
├── SKILL.md              # /petal slash command
│   # /petal init <folder>  — analyze brand assets, create .brand/
│   # /petal                 — inject relevant brand context
│   # /petal check [file]    — audit file against brand
│   # /petal voice <text>    — check copy against brand voice
│   # /petal color <name>    — look up a color
│   # /petal token <format>  — export design tokens
│
├── templates/             # Templates for .brand/ output
│   ├── identity.md
│   ├── colors.md
│   ├── typography.md
│   ├── voice.md
│   └── brand.json
│
└── scripts/
    └── init.sh            # Bootstrap script (mostly delegation to agent)
```

**That's it.** No MCP server. No JavaScript. No Playwright. No dependencies.

The "intelligence" is the agent reading the SKILL.md and following instructions. The skill tells the agent HOW to extract brand information using its native capabilities (Read, Bash, vision).

### MCP server comes later — when and only when:

- Agents need programmatic brand queries at high frequency
- Non-Claude agents need access
- CI/CD pipelines need brand checks

But start without it. Prove the model first.

---

## 8. Design Principles

1. **Files are the API** — `.brand/` is the interface. Any agent, any tool, any language can read it.
2. **LLMs do the heavy lifting** — don't write parsers. LLMs read PDFs, analyze images, understand design.
3. **One skill, one folder** — petal is ONE Claude Code skill. `.brand/` is ONE folder in the repo.
4. **Checkpoints, not gates** — petal reviews work at boundaries. It doesn't block work mid-flow.
5. **Batteries included but removable** — defaults work for everyone. Everything is overridable.
6. **No dependencies** — petal uses only what agents already have (file I/O, vision, text processing).
