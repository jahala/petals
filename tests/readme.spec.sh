#!/usr/bin/env bash
# Spec: the README tells the truth. Its "Try it" command runs from a clone and
# prints exactly the output shown under it, its version is petals --version,
# and it passes petals' own check. Prints TAP. Run from the repo root.
# After a deliberate change to the check's output: bash tests/readme.spec.sh --write
cd "$(dirname "$0")/.." || exit 1
BRAND=test/fixtures/brand-plotplot-v1.11.0/.brand
fails=0
ok() { if [ "$2" = 0 ]; then echo "ok - $1"; else echo "not ok - $1"; fails=$((fails+1)); fi }
is() { if "${@:2}"; then ok "$1" 0; else ok "$1" 1; fi }
# the Nth fenced block of the "## Try it" section
block() { awk -v want="$1" '/^## /{s=($0=="## Try it")} s && /^```/{n++; next} s && n==2*want-1' README.md; }

cmd=$(block 1 | grep -v '^git clone')
shown=$(block 2)
is "the Try it section has a command" [ -n "$cmd" ]
is "the Try it section shows its output" [ -n "$shown" ]
real=$(bash -c "$cmd" 2>&1)
if [ "${1:-}" = "--write" ]; then
  # after a deliberate change to the check's output: put the real run under the command
  python3 -I scripts/write-readme-output.py "$real"
  echo "wrote the Try it output in README.md"; exit 0
fi
is "the command prints exactly what the README shows" [ "$real" = "$shown" ]
[ "$real" = "$shown" ] || diff <(echo "$shown") <(echo "$real") | sed 's/^/# /'
ver=$(bash petals/bin/petals --version | awk '{print $NF}')
is "the README's version is petals --version ($ver)" grep -q "^Version $ver " README.md
out=$(bash petals/scripts/check.sh README.md --brand "$BRAND" --product petals 2>&1)
is "the README passes petals check" grep -q '^Result: PASS' <<<"$out"
echo "$out" | grep -E '^(ERROR|WARNING)' | sed 's/^/# /'
[ "$fails" = 0 ]
