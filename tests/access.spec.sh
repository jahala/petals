#!/usr/bin/env bash
# Spec: the check judges accessibility a page's source can show. Each rule
# locks a real person out when broken: an image without alt, a field without a
# label, a button without a name, focus removed with nothing in its place,
# zoom blocked, a clickable div. Each fixture line next to a broken one is an
# accepted form and stays quiet. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.11.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }

out=$(bash "$SCRIPT" test/fixtures/access/page.html --brand "$BRAND" --product petals 2>&1); rc=$?
t "zoom blocked in the viewport is an error"        'ERROR \[access\] line 4: the viewport blocks zooming' "$out"
t "an outline removed with no focus style is an error" 'ERROR \[access\] line 6: focus outline removed with no :focus-visible style' "$out"
t "an image without alt is an error"               'ERROR \[access\] line 10: an image without alt text' "$out"
n "alt=\"\" marks decoration and is fine"          'line 11:.*\[access\]|\[access\] line 11:' "$out"
n "an image with alt text is fine"                 '\[access\] line 12:' "$out"
t "a field with only a placeholder is an error"    'ERROR \[access\] line 13: a form field without a label' "$out"
n "a field a <label for> names is fine"            '\[access\] line 15:' "$out"
n "a field with aria-label is fine"                '\[access\] line 16:' "$out"
n "a field inside its label is fine"               '\[access\] line 17:' "$out"
n "hidden and submit inputs need no label"         '\[access\] line (18|19):' "$out"
t "an icon-only button with no name is an error"   'ERROR \[access\] line 20: a button with no name' "$out"
n "an icon button with aria-label is fine"         '\[access\] line 21:' "$out"
n "a button with text is fine"                     '\[access\] line 22:' "$out"
t "a clickable div is an error"                    'ERROR \[access\] line 23: a clickable <div>' "$out"
n "a static div is fine"                           '\[access\] line 24:' "$out"
n "quoted markup is not judged"                    '\[access\] line 25:' "$out"
t "the summary counts access"                      '^Access: +6 error\(s\)' "$out"
[ "$rc" = 1 ] && echo "ok - an inaccessible page fails the check" || { echo "not ok - an inaccessible page fails the check (rc $rc)"; fails=$((fails+1)); }

out=$(bash "$SCRIPT" test/fixtures/access/clean.html --brand "$BRAND" --product petals 2>&1)
n "focus restored with :focus-visible is fine, and a clean page has no access finding" '\[access\]' "$out"

out=$(bash "$SCRIPT" test/fixtures/access/page.html --brand "$BRAND" --product petals --format sarif 2>&1)
for r in img-alt unlabelled-field unnamed-button focus-removed zoom-blocked fake-button; do
  t "SARIF names access/$r" "\"ruleId\": *\"access/$r\"" "$out"
done
echo; echo "$fails failure(s)"; exit "$fails"
