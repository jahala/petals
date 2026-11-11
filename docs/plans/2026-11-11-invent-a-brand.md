# Inventing a brand from scratch (issue #5)

2026-11-11. The owner's decision of 2026-11-05 stands: when a project has no brand,
petals invents one and holds every agent to it. A brand that exists is only read.
This plan says how petals guides the agent through it, what is the agent's
judgement and what is a script's arithmetic, and in what order it lands.

## What a good outcome looks like

A developer starts a project with no brand. One session later it has a `.brand/`
that:

- came from what the product is for, not from the agent's default taste;
- the owner chose by eye from three real options;
- passes contrast in light and dark, and has no near-duplicate colours;
- carries a receipt of every choice, so anyone can see what was generated;
- is the same files, tokens, book and check as an extracted brand;
- has starter components with contracts, so the next agent reuses instead of
  rebuilding.

From then on it is the brand like any other.

## Kill criteria

The feature fails, and the deliverable becomes the written learning, if:

1. Two projects with different briefs get brands a reader cannot tell apart
   (three pages each, from separate agent sessions, judged against
   `tests/kill-test/rubric.md`).
2. Shown the three dealt options for a real project, the owner would ship none.
3. Pages built on an invented brand fail its own check more than pages built on
   an extracted one (the brand is incoherent, not the agent).

## Step 0: one brand format, read by every script (#35)

Found while planning. petals' scripts were tuned on one brand:

- `export-tokens.sh` derives colour tokens only from `--pp-*` properties.
- `check.sh` reads contrast pairs from a `## Contrast Pairings` table.
- The faux-style check reads weights and styles from the font table.

The templates write `--color-*`, an `## Approved Combinations` table and a
font table with no weights or styles. So a brand built from the templates,
extracted or invented, gets no colour tokens, no contrast-pair check and no
faux-style check. The templates also carry em dashes.

Fix first, test first: fill the templates with a known non-plotplot brand
(a fixture), and require `export-tokens.sh` to derive every colour,
`check.sh` to judge its pairs, and the faux-style rule to read its faces. The
scripts read the prefix the brand's own CSS block uses instead of assuming
one. Every later step writes this format.

## The flow

### 1. Decide that there is no brand

No `.brand/`, no `.petalsrc`. But a project may already have a de facto style:
CSS custom properties, a framework theme config, chosen fonts. Then the agent
offers extraction from the codebase first (`/petals init <folder>`), since that
style exists and is only read. Invention is for a project with nothing.

### 2. Ask about the product, not the look

At most three questions a round, two rounds at most, product truth only:

- who it is for and the one job it does for them;
- the tone, asked as an extreme to pick between (calm or loud, plain or
  playful, technical or warm), because "clean and modern" decides nothing;
- what is fixed already: a name, a colour the owner loves, a logo, a font
  licence, an accessibility requirement.

An unanswered question is recorded as `undecided`, never guessed. "Go ahead"
skips the rest. The answers go into `.brand/DESIGN.md` as the brief.

This is a recipe in `references/invent.md` that the agent follows. It needs
no command.

### 3. Deal three directions

A small library of starter presets in petals' own format, five to eight, each
a complete palette (light and dark), a type pairing with the weights it
ships, and spacing, radius and motion scales. A preset holds no layout and
no components.

Three are dealt, matched to the brief's tone and skipping the ones dealt
most recently, so projects do not converge. The history is a small file in
the user's state folder that keeps the last twenty deals and drops older ones.

The owner's seeds shape each dealt preset (the palette approach agreed on
#5): a colour they love is marked exact, bounded or flexible, and the preset
is bent around it.

### 4. The owner chooses by eye

Each dealt direction is rendered as a specimen page in its own tokens: the
palette with measured contrast, type specimens, a button in every state, a
form, a card. `petals review` opens the three behind one index. The owner
picks one. "None of these" deals three more.

### 5. Write the brand

The chosen direction becomes a normal `.brand/`:

- the template files, filled, in the step 0 format;
- `tokens.css` and `tokens.json` derived by `export-tokens.sh`;
- `.brand/receipt.md`: the brief, the seeds, the preset, every value changed
  to meet a rule and why;
- every generated value marked as generated, so the owner can replace it and
  the marker goes with it;
- a voice from the brief: personality traits and a tone spectrum from the
  tone answer, and a starter list of forbidden filler (empty claims and
  buzzwords), all marked generated. House rules such as em dashes stay
  undecided until the owner sets them;
- fonts with an open licence only, with the loading lines typography.md gives
  pages, so every page and the review index load the same faces;
- no logo. The hard rule stands: petals never invents a logo. `identity.md`
  records the logo as undecided, and a wordmark set in the heading face is
  allowed until there is one.

### 6. Starter components

The controls every project needs (button, input, checkbox, radio, toggle,
select, link) as one stylesheet of classes built only from the tokens, with a
contract for each in `.brand/components/` (the #6 format) and a preview page
that forces every state. A project on a component framework wraps these
classes in its own components, at the home the contract names. From then on
the reuse check holds every page to them.

## The agent's judgement and the scripts' arithmetic

The agent judges what needs context: reading the product, asking the
questions, matching tone to directions, explaining the options. A script
does what must be exact, once:

- bend a preset around the seeds and hold every contrast floor in both
  themes;
- hold the colour distance rules (#14);
- render the specimen pages;
- deal from the history;
- fill the templates and write the receipt.

The generator's contrast and colour-distance arithmetic must give the same
answers as `check.sh`'s, or a brand could be written that its own check
fails. A test compares the two on every preset, and the check judging the
written brand is the final word.

Inventing a brand happens once per project, and rare tasks are recipes, not
commands. This is the exception, because the arithmetic is error-prone and a
wrong contrast ratio ships to every page. So there is one script,
`scripts/new-brand.py` (deal, specimen, write), that the recipe calls. It adds
no `petals` subcommand. Python 3 only, like `marks.py`.

## Order of landing

Each is one pull request, test first, green on Linux and macOS.

1. Step 0: one brand format the scripts read, proved on a non-plotplot fixture.
2. The preset format and a first two presets, with the contrast and distance
   rules held in both themes (`tests/presets.spec.sh`). Presets are taste:
   the owner sees each one on a specimen board before it ships, these two
   included.
3. `new-brand.py write`: a preset becomes `.brand/` with markers and a receipt,
   and `check.sh` runs on it unchanged (`tests/init-new.spec.sh`).
4. Specimen pages, the deal with its history, and choosing through
   `petals review` (`tests/presets-choose.spec.sh`).
5. The recipe in `references/invent.md`, the SKILL.md entry, and the README's
   scope line. The owner's 2026-11-05 decision changes "petals reads the
   brand; it never decides it", and that line changes in this PR.
6. Starter components with contracts and preview pages.
7. The remaining presets, shown to the owner on the same board before they ship.
8. The kill test.

## What this plan leaves out

- A taste of petals' own. No banned hues or house styles: the presets are
  varied on purpose, and the owner chooses.
- Images, illustration and logo generation.
- Page layouts and templates. petals owns the brand, not the page.
- A browser-rendered check. Specimens are shown to a person; the check stays
  source-only.
