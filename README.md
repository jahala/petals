# petals

Brand intelligence for coding agents. petals turns your brand guidelines into
files your agent discovers and uses — every session, every project, without a
hex code pasted into a prompt.

petals is a design assist for agents: it informs how the agent designs inside
your brand before a line is generated, and audits what came out after. It is
not a design editor, and it will not invent your brand for you.

**[Landing page](index.html) · [Brand book example](.brand/book.html) · [Feature map](docs/tend/overview.html)**

## Quickstart

petals is a [Claude Code skill](petals/SKILL.md) — markdown the agent reads,
plus a small set of shell scripts. No build, no server, no account.

```
# copy the skill into your project
cp -r petals/ <your-project>/petals/

# extract a brand from whatever you have — a PDF, a folder of assets, a deck
/petals init brand-assets/

# or connect to a central brand repository
/petals init --from github.com/yourcompany/brand
```

Extraction writes `.brand/` — seven markdown files (colors, typography,
layout, surface, voice, identity, DESIGN) plus two derived machine views
(`tokens.css`, `tokens.json`) and copies your logo byte-for-byte. Only
explicit values are written; anything missing is flagged for a human, never
guessed. From then on the agent reads the brand before generating UI or copy.

## The five dimensions

`/petals check <file>` audits generated output against the brand:

| Dimension | Against | Catches |
|-----------|---------|---------|
| color | colors.md | off-palette hexes (with nearest match), illegible pairs (measured contrast) |
| typography | typography.md | wrong families, body text in a heading font |
| layout | layout.md | off-scale spacing, invented breakpoints |
| surface | components.md | off-scale radii, bouncy easings, un-tinted shadows |
| voice | voice.md | forbidden terms (with replacements), banned synonyms, casing |

The deterministic core runs without an agent:

```
bash petals/scripts/check.sh src/components/Hero.tsx
```

Milliseconds, zero tokens, exact. The agent adds what math cannot:
typography role classification and tone. Three lines of defense — the skill
at generation time, an editor hook at edit time, CI at merge time (recipes
in [SKILL.md](petals/SKILL.md)).

## The brand book

`/petals book` renders the whole `.brand/` directory as one self-contained
page — the brand's human face. Palette with measured contrast, type
specimens, component exemplars an agent can copy verbatim, and every
extraction flag waiting as a question at the top. The book is set in *your*
brand, chrome included; petals has no visual identity inside your project.

## Distribution

A central brand repo serves many projects. `/petals update` syncs, preserves
project overrides, regenerates the machine views, and reports the blast
radius — every file the new brand version flags that the old one did not.
An update that lands silently is half an update.

## Honest scope

- petals reads what exists; it does not design.
- It checks rules in files, not rendered layouts.
- A missing value is flagged for a human, never approximated.
- The brand is your designers'; petals carries their decisions.

## Development

```
bash tests/check.spec.sh     # deterministic engine spec
```

petals is mapped and verified with [tend](docs/tend/overview.html) — every
capability is a bet with checks, audits, and evidence. This repository is
also petals' own first consumer: the landing page and brand book pass their
own `/petals check`.

Version 0.1.0 · part of the plotplot garden, alongside tend and tilth.
