#!/usr/bin/env bash
# Spec: a spacing value equal to a stroke token (a 1px hairline) is not off
# the spacing scale. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
printf '.tiles { gap: 1px; }\n.seams { gap: var(--pp-stroke-hairline); }\n.rule { margin-top: 2px; }\n.off { gap: 13px; }\n' > "$PROBE/tiles.css"
out=$(bash "$SCRIPT" "$PROBE/tiles.css" --brand "$BRAND" 2>&1)
n "a 1px hairline gap is on brand" 'line 1: 1px is outside' "$out"
n "a stroke-token reference is on brand" 'line 2:' "$out"
n "a 2px stroke-rule value is on brand" 'line 3: 2px is outside' "$out"
t "an off-scale value still warns" 'WARNING \[layout\] line 4: 13px is outside the spacing scale' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
