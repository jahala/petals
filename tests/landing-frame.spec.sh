#!/usr/bin/env bash
# Spec: the frame on petals' landing page (index.html) is a real run. It must
# match what petals check prints for test/fixtures/landing/hero.html against the
# frozen brand the frame names, line for line, and the exit code in its title.
# The proof band under it must name the real version and dimension count;
# tests/run-all.sh holds its test count, since only it sees every suite.
# Prints TAP. Run from the repo root. After a deliberate change to the check's
# output, rewrite the frame from a real run: bash tests/landing-frame.spec.sh --write
cd "$(dirname "$0")/.." || exit 1
BRAND=test/fixtures/brand-plotplot-v1.11.0/.brand
fails=0
ok() { if [ "$2" = 0 ]; then echo "ok - $1"; else echo "not ok - $1"; fails=$((fails+1)); fi }
is() { if "${@:2}"; then ok "$1" 0; else ok "$1" 1; fi }

real=$(bash petals/scripts/check.sh test/fixtures/landing/hero.html --brand "$BRAND" --product petals 2>&1)
code=$?
if [ "${1:-}" = "--write" ]; then
  # after a deliberate change to the check's output: render the real run into the frame
  python3 -I scripts/write-landing-frame.py "$real"
  echo "wrote the frame in index.html"; exit 0
fi
# the frame's text: the term-body pre, tags stripped, entities decoded, prompt line dropped
shown=$(awk '/<pre class="term-body">/{on=1} on{print} on&&/<\/pre>/{exit}' index.html \
  | sed -e 's/<[^>]*>//g' -e 's/&quot;/"/g' -e "s/&#39;/'/g" -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&amp;/\&/g' \
  | sed '1d')

is "index.html has a term-body frame" [ -n "$shown" ]
is "the frame shows the check's real output" [ "$shown" = "$real" ]
[ "$shown" = "$real" ] || diff <(echo "$shown") <(echo "$real") | sed 's/^/# /'
grep -q "checked against plotplot v1.11.0 · exit $code<" index.html; ok "the frame's title names the brand and exit $code" $?
grep -q '^\$ petals check hero.html' <(awk '/<pre class="term-body">/{on=1} on{print;exit}' index.html | sed 's/<[^>]*>//g'); ok "the frame's prompt names the demo file" $?
band=$(grep -o 'id="proof-title">petals [0-9.]*,' index.html)
ver=$(echo "$band" | sed -E 's/.*petals ([0-9.]+),.*/\1/')
is "the proof band's version is petals --version ($ver)" [ "$ver" = "$(bash petals/bin/petals --version | awk '{print $NF}')" ]
dims=$(grep -o '<dt>dimensions checked</dt><dd>[0-9]*' index.html | grep -oE '[0-9]+$')
real_dims=$(echo "$real" | grep -cE '^(Colors|Layout|Surface|Voice|Typography|Content|Access|Reuse):')
is "the proof band's dimension count is the check's ($real_dims)" [ "$dims" = "$real_dims" ]
[ "$fails" = 0 ]
