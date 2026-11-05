#!/usr/bin/env bash
# Spec: check.sh judges the font families a page loads and declares against
# typography.md. Known cases are real pages saved on 2026-11-05,
# listed in test/fixtures/fonts/SOURCES.md. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
FX=test/fixtures/fonts
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }

for bed in tilth umbel pleach weeder mycelium; do
  out=$(bash "$SCRIPT" "$FX/bed-$bed.html" --brand "$BRAND" 2>&1); rc=$?
  t "$bed: loading Fraunces is a typography error" "ERROR \[typography\] line [0-9]+: .*Fraunces.* not a typography\.md family" "$out"
  t "$bed: the check fails" '^Result: FAIL' "$out"
  [ "$rc" -ne 0 ] && echo "ok - $bed: exit code non-zero" || { echo "not ok - $bed: exit code non-zero"; fails=$((fails+1)); }
done

out=$(bash "$SCRIPT" "$FX/plotplot-ai.html" --brand "$BRAND" 2>&1)
n "plotplot.ai: no typography errors" 'ERROR \[typography\]' "$out"
t "plotplot.ai: the summary counts typography" '^Typography: 0 error' "$out"

PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
# fallbacks after a brand family are fine; a brand family as a fallback is not enough
printf '<style>\nh1 { font-family: "Protest Riot", Georgia, serif; }\np { font-family: Inter, "Hanken Grotesk", sans-serif; }\ncode { font-family: var(--font-code); }\n</style>\n' > "$PROBE/stacks.html"
out=$(bash "$SCRIPT" "$PROBE/stacks.html" --brand "$BRAND" 2>&1)
n "a fallback after a brand family passes" 'line 2: .*Georgia' "$out"
t "a stack led by a non-brand family is an error" 'ERROR \[typography\] line 3: .*Inter' "$out"
n "a var() reference is not judged as a family" 'line 4' "$out"
n "a file that loads no fonts gets no never-loaded warning" 'never loads' "$out"
# a page that loads fonts but not one of the brand families is warned
printf '<link href="https://fonts.googleapis.com/css2?family=Hanken+Grotesk&family=JetBrains+Mono" rel="stylesheet">\n' > "$PROBE/partial.html"
out=$(bash "$SCRIPT" "$PROBE/partial.html" --brand "$BRAND" 2>&1)
t "a brand family the page never loads is a warning" 'WARNING \[typography\] .*Protest Riot.*never loads' "$out"
n "loading brand families is not an error" 'ERROR \[typography\]' "$out"
# @font-face counts as loading
printf '@font-face {\n  font-family: "Comic Neue";\n  src: url(x.woff2);\n}\n' > "$PROBE/face.css"
out=$(bash "$SCRIPT" "$PROBE/face.css" --brand "$BRAND" 2>&1)
t "an @font-face for a non-brand family is an error" 'ERROR \[typography\] line 2: .*Comic Neue' "$out"

echo; echo "$fails failure(s)"; exit "$fails"
