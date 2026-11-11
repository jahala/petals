# Inventing a brand from scratch (issue #5)

2026-11-11. The owner's decision of 2026-11-05 stands: when a project has no brand,
petals invents one and holds every agent to it. A brand that exists is only read.
Two rulings of 2026-11-11 shape it: no presets, so every direction is
generated from the brief; and petals helps make the logo too.
This plan says how petals guides the agent through it, what is the agent's
judgement and what is a script's arithmetic, and in what order it lands.

## What a good outcome looks like

A developer starts a project with no brand. One session later it has a `.brand/`
that:

- came from what the product is for, not from the agent's default taste;
- the owner chose by eye from three real options;
- has a mark and a wordmark the owner chose, with night and favicon versions;
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
2. Shown the three directions for a real project, the owner would ship none,
   or shown three marks, would use none.
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

### 3. Three directions from the brief

There is no library of presets. The agent drafts three directions from the
brief, as far apart as the brief allows. Each is a short request, not a
design:

- a key colour: the owner's own, marked exact, bounded or flexible (the
  palette approach agreed on #5), or one the agent picks for the brief;
- how loud the palette is, the temperature of its neutrals and its contrast
  level;
- a heading face and a body face, from open-licensed families;
- the shape (sharp, soft or round) and the density (compact or roomy).

A script turns each request into a full system: tints and shades, light and
dark neutrals, status colours with contrast floors in both themes, and the
type, spacing, radius and motion scales.

The same script refuses a set that is too alike (key colours too close, the
same faces) or too close to the last projects it made, and says why, so the
agent redrafts. That is what keeps projects from converging on an agent's
default look. The history is a small file in the user's state folder that
keeps the last twenty directions and drops older ones.

The faces come from a fact table of open-licensed families (category,
weights, italics, licence), so the script can confirm that every weight a
direction uses exists. It holds no pairings: pairing is the agent's judgement.

### 4. The owner chooses by eye

Each direction is rendered as a specimen page in its own tokens: the palette
with measured contrast, type specimens, a button in every state, a form, a
card. `petals review` opens the three behind one index. The owner picks one.
"None of these" sends the agent back to the brief for three more.

### 5. Write the brand

The chosen direction becomes a normal `.brand/`:

- the template files, filled, in the step 0 format;
- `tokens.css` and `tokens.json` derived by `export-tokens.sh`;
- `.brand/receipt.md`: the brief, the seeds, the chosen direction, every value changed
  to meet a rule and why;
- every generated value marked as generated, so the owner can replace it and
  the marker goes with it;
- a voice from the brief: personality traits and a tone spectrum from the
  tone answer, and a starter list of forbidden filler (empty claims and
  buzzwords), all marked generated. House rules such as em dashes stay
  undecided until the owner sets them;
- fonts with an open licence only, with the loading lines typography.md gives
  pages, so every page and the review index load the same faces;
- the mark and wordmark the owner chose in step 6.

### 6. A mark and a wordmark

petals helps make the logo the way it makes everything else: the agent
drafts, a script checks, the owner chooses. An owner who has a logo skips
this step.

There are no style rules. The mark's shape, weight and construction come from
the brief and the owner's choice; a grid or a line weight would be one
brand's taste imposed on every brand. Only what protects the people who see
the logo is checked:

- its colours come from the palette, so it belongs to the brand;
- it reads at browser-tab size: no line or gap thinner than one pixel when
  drawn at 16 pixels;
- it is visible on the light and the dark background, at 3:1 contrast or
  more, the accessibility floor for graphics;
- it is a clean, portable SVG: no embedded pictures, no outside files, no
  text that needs a font installed.

From the brief, the agent draws three mark candidates, each from a different
idea of what the product does, and a wordmark: the name set in the heading
face. `marks.py`, generalised beyond plotplot's beds, checks each one and
derives its night version and favicon tile. A board shows each candidate at
16, 32, 64 and 128 pixels, on paper and at night, on its tile and in a
browser tab, beside the wordmark. The owner picks one, or asks for three
more.

Rules follow the choice. Once the owner picks, petals writes down how that
mark is built (its grid, its weights, its inks) in `DESIGN.md`, so later
icons and product marks match it. The chosen files go into `.brand/assets/`,
and `identity.md` gets clear space, minimum size and what not to do, all
marked generated.

The page-level rule stays: an agent building a page uses the logo files in
`.brand/assets/` and never draws a logo inline.

### 7. Starter components

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

- turn a direction into a full system around the owner's seeds, holding
  every contrast floor in both themes;
- hold the colour distance rules (#14);
- refuse directions too alike, or too close to recent projects;
- render the specimen pages and the logo board;
- check the mark candidates and derive their night and favicon versions;
- fill the templates and write the receipt.

The generator's contrast and colour-distance arithmetic must give the same
answers as `check.sh`'s, or a brand could be written that its own check
fails. A test compares the two on every generated direction, and the check
judging the written brand is the final word.

Inventing a brand happens once per project, and rare tasks are recipes, not
commands. This is the exception, because the arithmetic is error-prone and a
wrong contrast ratio ships to every page. So there is one script,
`scripts/new-brand.py` (system, spread, specimen, write), that the recipe
calls, beside the generalised `marks.py`. It adds
no `petals` subcommand. Python 3 only, like `marks.py`.

## Order of landing

Each is one pull request, test first, green on Linux and macOS.

1. Step 0: one brand format the scripts read, proved on a non-plotplot
   fixture (#35).
2. `new-brand.py system`: a direction request becomes a full system, with the
   contrast and distance floors held in both themes and the same answers as
   `check.sh` (`tests/directions.spec.sh`).
3. `new-brand.py write`: a system becomes `.brand/` with markers and a
   receipt, and `check.sh` runs on it unchanged (`tests/init-new.spec.sh`).
4. The spread rule and its history, the specimen pages, and choosing through
   `petals review` (`tests/directions-choose.spec.sh`).
5. Logos: `marks.py` checks any brand's mark for palette, size, contrast and
   a clean SVG; the board; writing the chosen mark and its construction
   (`tests/logo.spec.sh`).
6. The recipe in `references/invent.md`, the SKILL.md entry and its logo
   rule, and the README's scope line. The owner's decisions change "petals
   reads the brand; it never decides it" and "never invent a logo", and both
   lines change in this PR.
7. Starter components with contracts and preview pages.
8. The kill test.

## What this plan leaves out

- A taste of petals' own. No banned hues or house styles: variety comes from
  the brief and the spread rule, and the owner chooses.
- Images and illustration.
- Page layouts and templates. petals owns the brand, not the page.
- A browser-rendered check. Specimens are shown to a person; the check stays
  source-only.
