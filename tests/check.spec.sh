#!/usr/bin/env bash
# Spec for petals/scripts/check.sh — the deterministic core of /petals check.
# Run from the repo root: bash tests/check.spec.sh
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BAD=test/fixtures/check/bad.css
GOOD=test/fixtures/check/good.css
fails=0
t() { # t <description> <grep-pattern> <output>
  if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi
}
[ -f "$SCRIPT" ] || { echo "not ok - check.sh does not exist"; exit 1; }

OUT_BAD=$(bash "$SCRIPT" "$BAD" --brand test/fixtures/brand-plotplot-v2.0.0/.brand --product petals 2>&1); RC_BAD=$?
OUT_GOOD=$(bash "$SCRIPT" "$GOOD" --brand test/fixtures/brand-plotplot-v2.0.0/.brand --product petals 2>&1); RC_GOOD=$?

t "off-palette hex is an error with a suggestion"  'ERROR \[color\] line 2: #3B82F6 is not in the palette\. Did you mean #4E88A6' "$OUT_BAD"
t "low contrast pair under 3.0 is an error"        'ERROR \[color\] line 8: #E588A0 on #357E2C is 2\.0[0-9]:1' "$OUT_BAD"
t "documented decorative pair used for words is an error" 'ERROR \[color\] line 7: #E89227 on #FAF5E9 is 2\.2[0-9]:1.*documented decorative-only pair' "$OUT_BAD"
t "13px off the 4px scale is a warning"            'WARNING \[layout\] line 3: 13px is outside the spacing scale\. Did you mean 12px' "$OUT_BAD"
t "undocumented breakpoint is a warning"           'WARNING \[layout\] line 10: 700px is not a documented breakpoint' "$OUT_BAD"
t "off-scale radius is a warning"                  'WARNING \[surface\] line 4: 9px is off the radius scale\. Did you mean 8px or 10px' "$OUT_BAD"
t "overshoot bezier is a warning"                  'WARNING \[surface\] line 5: cubic-bezier with overshoot' "$OUT_BAD"
t "pure-black shadow is a warning"                 'WARNING \[surface\] line 6: shadow uses pure black' "$OUT_BAD"
t "forbidden term is an error with replacement"    'ERROR \[voice\] line 9: "[Ss]upercharge" is a forbidden term\. Use "strengthen' "$OUT_BAD"
t "banned terminology synonym is a warning"        'WARNING \[voice\] line 9: "brand bible"' "$OUT_BAD"
t "capitalized product name is a warning"          'WARNING \[voice\] line 9: "Petals" — product names are lowercase' "$OUT_BAD"
t "cross-product accent warns by name"             'WARNING \[color\] line 11: #D6502F is tend' "$OUT_BAD"
t "nearest-match names whose accent"               'line 12: #D97757 is not in the palette\. Did you mean #D6502F \(tend' "$OUT_BAD"
if echo "$OUT_GOOD" | grep -q 'E588A0'; then echo "not ok - own product accent passes silently"; fails=$((fails+1)); else echo "ok - own product accent passes silently"; fi
t "summary block present"                          '--- petals check \(deterministic\) ---' "$OUT_BAD"
t "typography counts families, roles stated as agent-side" 'Typography: [0-9]+ error.*roles stay with the agent' "$OUT_BAD"
t "bad file fails"                                 '^Result: FAIL' "$OUT_BAD"
[ "$RC_BAD" -ne 0 ] && echo "ok - bad exit code non-zero" || { echo "not ok - bad exit code"; fails=$((fails+1)); }
if echo "$OUT_GOOD" | grep -q '46913C'; then echo "not ok - documented labels pair passes silently"; fails=$((fails+1)); else echo "ok - documented labels pair passes silently"; fi
if echo "$OUT_GOOD" | grep -q '18px'; then echo "not ok - radius scan ignores width/height on the same line"; fails=$((fails+1)); else echo "ok - radius scan ignores width/height on the same line"; fi
if echo "$OUT_GOOD" | grep -qi 'supercharge'; then echo "not ok - quoted bad-example voice hits are skipped"; fails=$((fails+1)); else echo "ok - quoted bad-example voice hits are skipped"; fi
t "good file passes every dimension"               '^Result: PASS' "$OUT_GOOD"
[ "$RC_GOOD" -eq 0 ] && echo "ok - good exit code zero" || { echo "not ok - good exit code ($RC_GOOD): $OUT_GOOD"; fails=$((fails+1)); }
# a correctly lowercase product name passes silently (issue #3)
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
printf '<p>petals reads the brand.</p>\n<p>Petals reads the brand.</p>\n' > "$PROBE/casing.html"
OUT_CASE=$(bash "$SCRIPT" "$PROBE/casing.html" --brand test/fixtures/brand-plotplot-v2.0.0/.brand --product petals 2>&1)
if echo "$OUT_CASE" | grep -q 'line 1: "petals" — product names are lowercase'; then echo "not ok - lowercase product name passes silently"; fails=$((fails+1)); else echo "ok - lowercase product name passes silently"; fi
t "capitalised product name still warns"            'line 2: "Petals" — product names are lowercase' "$OUT_CASE"
# a relative file argument resolves from where the script is called, not the project root
OUT_SUB=$(cd tests && bash ../$SCRIPT ../$BAD --brand ../test/fixtures/brand-plotplot-v2.0.0/.brand --product petals 2>&1)
t "relative paths resolve from the caller's directory" '^Result: FAIL' "$OUT_SUB"

echo; echo "$fails failure(s)"; exit "$fails"
