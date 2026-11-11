# petals

Brand that agents read. petals carries your brand into everything a coding
agent builds, and checks what came out: a skill the agent reads before it
writes a line, and a deterministic check after, with no model in the loop.

**[Landing page](https://jahala.github.io/petals/) · [Feature map](https://jahala.github.io/petals/docs/tend2/garden.tend2.html)**

## Try it

The repository carries a frozen copy of a real brand and a draft hero with
the slips an agent makes: a font outside the brand, a framework blue,
off-scale spacing, a pure black shadow, a forbidden term, placeholder copy
and a link to nowhere. Check it:

```
git clone https://github.com/jahala/petals && cd petals
petals/bin/petals check test/fixtures/landing/hero.html \
  --brand test/fixtures/brand-plotplot-v1.11.0/.brand --product petals
```

```
WARNING [layout] line 3: 13px is outside the spacing scale. Did you mean 12px or 16px?
WARNING [surface] line 3: 7px is off the radius scale. Did you mean 6px or 8px?
ERROR [typography] line 4: "Inter" is not a typography.md family (Protest Riot, Hanken Grotesk, JetBrains Mono).
ERROR [color] line 4: #3B82F6 is not in the palette. Did you mean #4E88A6?
ERROR [color] line 5: #000 is not in the palette. Did you mean #1C1610?
WARNING [surface] line 5: shadow uses pure black. Brand shadows are ink-tinted (components.md Shadow Recipes).
ERROR [content] line 7: placeholder copy. Write the real words, or keep this page under a mockup path.
ERROR [voice] line 8: "supercharge" is a forbidden term. Use "strengthen, improve, clarify" instead.
ERROR [content] line 9: href="#" goes nowhere. Link the real page, or keep this page under a mockup path.

--- petals check (deterministic) ---
Colors:   2 error(s), 0 warning(s)
Layout:   0 error(s), 1 warning(s)
Surface:  0 error(s), 2 warning(s)
Voice:    1 error(s), 0 warning(s)
Typography: 1 error(s), 0 warning(s) (families; heading and body roles stay with the agent)
Content:  2 error(s), 0 warning(s), 0 note(s) (production stage)
Reuse:    no contracts (.brand/components/ holds none)
Result: FAIL — 6 error(s) to fix, 3 warning(s) to review.
```

The run takes milliseconds, makes no network calls and exits 1. Add
`--format sarif` for one SARIF 2.1.0 log instead of text.

## Install

petals needs bash, awk, git and python3. There is no build and no account.

```
git clone https://github.com/jahala/petals
ln -s "$PWD/petals/petals" ~/.claude/skills/petals          # the skill
ln -s "$PWD/petals/petals/bin/petals" ~/.local/bin/petals   # the command
```

Then give a project its brand, from a folder of guidelines (a PDF, assets,
a deck) or from a central brand repository:

```
/petals init brand-assets/
/petals init --from github.com/yourcompany/brand
```

Extraction writes `.brand/`: seven markdown files (colors, typography,
layout, components, voice, identity, DESIGN), two token files derived from
them (`tokens.css`, `tokens.json`) and a byte-for-byte copy of your logo.
Only stated values are written. Anything missing is flagged for a person,
never guessed. From then on the agent reads the brand before it builds UI or
writes copy.

## What it checks

| Dimension  | Against        | Finds                                                              |
|------------|----------------|--------------------------------------------------------------------|
| color      | colors.md      | off-palette colours (with the nearest match), contrast below the minimum in each theme |
| typography | typography.md  | fonts the brand does not use, weights or italics a face does not ship |
| layout     | layout.md      | spacing and breakpoints off the scale                              |
| surface    | components.md  | radii, strokes and shadows off the tokens                          |
| voice      | voice.md       | forbidden terms with their replacements, banned synonyms, em dashes |
| content    | the stage      | placeholder copy, dummy contacts, dead links                       |
| reuse      | components/    | a control rebuilt by hand where a component contract covers it     |

Two judgments stay with the agent: whether a heading or body role got the
right face, and tone.

## Four faces on one check

| Command | Does |
|---------|------|
| `petals check <file>` | judges one file against the brand and prints each finding, or one SARIF log |
| `petals gate [--base <ref>]` | judges the files a change touches, with the brand and rules the base carries, so a change cannot loosen its own rules |
| `petals guard pre-commit` | judges what is staged when a commit is made, and refuses the commit over an error |
| `petals review <page>` | opens pages in your browser behind an index, and leaves nothing behind |

Exit 0 is clean or warnings only, exit 1 is at least one error, and exit 3
means the check could not judge (no brand, for example) and says why. Exit 3
is a refusal, not a pass.

To check every commit, plant the hooks:

```
printf '#!/bin/sh\nexec petals guard pre-commit\n' > .git/hooks/pre-commit
printf '#!/bin/sh\nexec petals guard commit-msg "$1"\n' > .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit .git/hooks/commit-msg
```

A finding can go through on the record with a trailer on the commit,
`Petals-allow: <rule> <reason>`. It stays in the log as a note that carries
the reason. A trailer without a reason allows nothing.

## Mockups and production

Believable filler is how a mockup gets judged, so content findings are
errors in production and notes in a mockup. Brand rules are the same in
both. Mark mockup paths in `.petalsrc`:

```yaml
stages:
  mockup:
    - docs/designs/**
```

## One brand, many products

A brand can be a family: an umbrella (the shared palette, type, layout,
surface and voice) plus a layer per product at `.brand/products/<product>/`.
A product layer holds only its differences, such as its accent, mark,
tagline and terminology; everything else comes from the umbrella. The check,
the book and the tokens read both, and another product's accent in your UI
warns by name. A single-brand project stays flat. This repository is the
example: plotplot is the umbrella and petals a product layer.

## The brand book and updates

`/petals book` renders `.brand/` as one self-contained page set in your
brand: the palette with measured contrast, type specimens, component
examples an agent can copy, and every extraction flag as a question at the
top.

`/petals update` pulls a new version from the central brand repository,
keeps the project's overrides, rebuilds the tokens, and lists every file the
new version flags that the old one did not.

## Scope

- petals reads the brand you have; it does not design.
- It checks rules in files, not rendered layouts.
- A missing value is flagged for a person, never approximated.
- The brand is your designers'. petals carries their decisions.

## Development

```
bash tests/run-all.sh        # every spec suite, as TAP
```

petals is mapped with [tend2](docs/tend2/garden.tend2.html): every
capability is a loop with checks, and only the verifier marks a check as
passed. petals is also its own first user: the landing page passes its own
check (`tests/self-check.spec.sh`), and this README's output above is held
to a real run (`tests/readme.spec.sh`).

## Support

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/jahala)

## License

MIT

---

Version 0.2.0 · part of the plotplot garden.
