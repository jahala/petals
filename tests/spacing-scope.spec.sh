#!/usr/bin/env bash
# Spec: the spacing rule judges only the values of spacing declarations
# (padding, margin, gap). A radius, width or font size sharing the line is
# judged by its own rule or not at all, so one value is never reported twice.
# Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.11.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
printf '.a { padding: 16px; border-radius: 7px; }\n.b { margin: 8px; width: 13px; font-size: 15px; }\n.c { padding: 13px; border-radius: 8px; }\n.d { gap: 4px 13px; }\n' > "$PROBE/page.css"
out=$(bash "$SCRIPT" "$PROBE/page.css" --brand "$BRAND" --product petals 2>&1)
n "a radius beside padding is not judged as spacing" 'line 1: 7px is outside the spacing scale' "$out"
t "the radius is still judged as a radius" 'WARNING \[surface\] line 1: 7px is off the radius scale' "$out"
n "a width beside margin is not judged as spacing" 'line 2: 13px is outside the spacing scale' "$out"
n "a font size beside margin is not judged as spacing" 'line 2: 15px is outside the spacing scale' "$out"
t "off-scale padding still warns" 'WARNING \[layout\] line 3: 13px is outside the spacing scale' "$out"
t "every value of a shorthand is judged" 'WARNING \[layout\] line 4: 13px is outside the spacing scale' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
