# directions

Four direction requests written for `tests/directions.spec.sh` on 2026-11-11,
each beside the system `petals/scripts/new-brand.py system` prints for it. The
names are invented.

- `seeded-exact`: the owner's yellow held exact. It is too light for words on
  the light background, so it gets a primary-text shade and dark on-primary text.
- `hue-only`: no colour given, a wheel hue of 160.
- `high-contrast`: a flexible blue seed at high contrast (reading 7:1).
- `bounded`: a blue seed that may move 6 in CIEDE2000. In the light theme that is
  not far enough to carry words, so it stays the seed and takes primary-text.

The spec requires each stored system to equal what the script prints now. A
change to the script's rules changes the systems; regenerate them with
`python3 -I petals/scripts/new-brand.py system <name>.request.json > <name>.system.json`
and read the diff before committing it.
