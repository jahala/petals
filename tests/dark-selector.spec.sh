#!/usr/bin/env bash
# Spec: a brand names its own dark-theme selector (issue #52). The dark
# selector is whatever selector colors.md's CSS block gives its dark
# overrides: [data-theme="dark"], .dark, :root.dark, or :root inside
# @media (prefers-color-scheme: dark). brand_dark_selector in lib/common.sh
# reads it once. export-tokens.sh derives the dark tokens from that block and
# writes tokens.css's dark block under the same selector; check.sh holds a
# page's rules under it to the dark theme. Two dark blocks with different
# values, or a block petals cannot read, are refused and named, never
# guessed. The brands are copies of the larch fixture, built here; the
# plotplot fixtures derive exactly what they commit. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
EXPORT=petals/scripts/export-tokens.sh
CHECK=petals/scripts/check.sh
FX=test/fixtures/brand-template/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1: wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1: did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
is() { if [ "$2" = "$3" ]; then echo "ok - $1"; else echo "not ok - $1: wanted $3, got $2"; fails=$((fails+1)); fi }
# replace text in a file, the same on macOS and Linux (sed -i differs between them)
subst() { python3 -I -c 'import sys; p, a, b = sys.argv[1:]; s = open(p).read(); assert a in s, a; open(p, "w").write(s.replace(a, b))' "$1" "$2" "$3"; }
# the value of one token in tokens.json, by its path, or "" when absent
jval() { python3 -I -c 'import json, sys
d = json.load(open(sys.argv[1]))
for k in sys.argv[2].split("."):
    d = d.get(k, {}) if isinstance(d, dict) else {}
print(d.get("$value", "") if isinstance(d, dict) else "")' "$1" "$2" 2>/dev/null; }

P=$(mktemp -d); trap 'rm -rf "$P"' EXIT

# The larch fixture writes its dark theme as [data-theme="dark"] { ... }.
DARK_OPEN='[data-theme="dark"] {'
DARK_BODY='  --larch-primary: #7FC29B;
  --larch-accent: #E0A83A;
  --larch-text: #ECE8DC;
  --larch-text-soft: #B5B9AE;
  --larch-bg: #141A16;
  --larch-surface: #1D2520;
  --larch-border: #34403A;
}'
grep -qF "$DARK_OPEN" "$FX/colors.md" || { echo "not ok - the larch fixture still writes its dark block as $DARK_OPEN"; exit 1; }

# A Night column, so the night shadow rule has something to hold a page to.
cp -R "$FX" "$P/base"
subst "$P/base/components.md" '| Token | Value | Usage |
|-------|-------|-------|
| shadow-rest | `0 1px 2px rgba(31, 42, 36, 0.08)` | Resting panes |' '| Token | Value | Night | Usage |
|-------|-------|-------|-------|
| shadow-rest | `0 1px 2px rgba(31, 42, 36, 0.08)` | `0 1px 2px rgba(5, 8, 6, 0.4)` | Resting panes |'
subst "$P/base/components.md" '| shadow-lift | `0 4px 16px rgba(31, 42, 36, 0.12)` | Hover lift |' '| shadow-lift | `0 4px 16px rgba(31, 42, 36, 0.12)` | | Hover lift |'
subst "$P/base/components.md" '| shadow-float | `0 12px 32px rgba(31, 42, 36, 0.16)` | Floating panels |' '| shadow-float | `0 12px 32px rgba(31, 42, 36, 0.16)` | | Floating panels |'

brand() { cp -R "$P/base" "$P/$1"; }
brand dot;     subst "$P/dot/colors.md" "$DARK_OPEN" '.dark {'
brand rootdot; subst "$P/rootdot/colors.md" "$DARK_OPEN" ':root.dark {'
brand ink;     subst "$P/ink/colors.md" "$DARK_OPEN" '.theme-ink {'
brand media;   subst "$P/media/colors.md" "$DARK_OPEN
$DARK_BODY" "@media (prefers-color-scheme: dark) {
  :root {
$(printf '%s\n' "$DARK_BODY" | sed 's/^/  /')
}"
# two dark blocks under two selectors with the same values: one meaning
brand twin;    subst "$P/twin/colors.md" "$DARK_OPEN
$DARK_BODY" "$DARK_OPEN
$DARK_BODY

.dark {
$DARK_BODY"
# two dark blocks under two selectors with different values
brand clash;   subst "$P/clash/colors.md" "$DARK_OPEN
$DARK_BODY" "$DARK_OPEN
$DARK_BODY

.dark {
$(printf '%s\n' "$DARK_BODY" | sed 's/--larch-bg: #141A16/--larch-bg: #1D2520/')"
# a dark block that never closes
brand open;    subst "$P/open/colors.md" '  --larch-border: #34403A;
}' '  --larch-border: #34403A;'

dark_of() { # the lines of tokens.css from the line that opens $2 to the end
  awk -v open="$2" 'index($0, open) == 1 { f=1 } f' "$1" 2>/dev/null; }

# 1. each brand selector derives dark tokens written under that selector
for b in dot rootdot media; do
  out=$(bash "$EXPORT" "$P/$b" 2>&1); rc=$?
  is "export-tokens.sh derives the $b brand" "$rc" 0
  [ "$rc" -eq 0 ] || printf '%s\n' "$out" | sed 's/^/# /'
  is "tokens.json's dark group holds the $b brand's dark primary" "$(jval "$P/$b/tokens.json" dark.color.primary)" "#7FC29B"
  is "tokens.json's light group keeps the $b brand's light primary" "$(jval "$P/$b/tokens.json" color.primary)" "#2F6B4F"
  is "the night shadow is a dark token for the $b brand" "$(jval "$P/$b/tokens.json" dark.shadow.rest)" "0 1px 2px rgba(5, 8, 6, 0.4)"
  t "tokens.css's :root keeps the light primary ($b)" '^  --larch-primary: #2F6B4F;$' "$(awk '/^:root \{/,/^\}/' "$P/$b/tokens.css")"
done
t "tokens.css writes the dark block under .dark" '^\.dark \{
  --larch-primary: #7FC29B;' "$(dark_of "$P/dot/tokens.css" '.dark {')"
t "tokens.css writes the dark block under :root.dark" '^:root\.dark \{
  --larch-primary: #7FC29B;' "$(dark_of "$P/rootdot/tokens.css" ':root.dark {')"
t "tokens.css writes the dark block as :root inside the media query" '^@media \(prefers-color-scheme: dark\) \{
  :root \{
    --larch-primary: #7FC29B;' "$(dark_of "$P/media/tokens.css" '@media')"
t "the media query block closes both braces" '^    --larch-shadow-rest: 0 1px 2px rgba\(5, 8, 6, 0\.4\);
  \}
\}$' "$(dark_of "$P/media/tokens.css" '@media')"
for b in dot rootdot media; do
  n "tokens.css never rewrites the $b brand's selector to [data-theme=\"dark\"]" 'data-theme' "$(cat "$P/$b/tokens.css")"
done

# 2. --check passes after deriving and catches a changed dark value
for b in dot media; do
  out=$(bash "$EXPORT" "$P/$b" --check 2>&1); rc=$?
  is "--check passes after deriving the $b brand" "$rc" 0
  t "--check says the $b brand's tokens match" '^tokens match the markdown$' "$out"
  cp -R "$P/$b" "$P/$b-stale"
  subst "$P/$b-stale/colors.md" '  --larch-primary: #7FC29B;' '  --larch-primary: #ECE8DC;'
  out=$(bash "$EXPORT" "$P/$b-stale" --check 2>&1); rc=$?
  is "--check exits 1 when the $b brand's dark value changes" "$rc" 1
  t "--check names the $b brand's stale dark token" 'DIFF css \[dark\]--larch-primary committed: #7FC29B derived: #ECE8DC' "$out"
done
cp -R "$P/dot" "$P/moved"
subst "$P/moved/colors.md" '.dark {' ':root.dark {'
out=$(bash "$EXPORT" "$P/moved" --check 2>&1); rc=$?
is "--check exits 1 when the brand moves its dark block to another selector" "$rc" 1
t "--check names the dark block tokens.css still carries under the old selector" 'DIFF css \[dark\]--larch-primary committed: #7FC29B derived: \(absent\)|DIFF css \[\.dark\]--larch-primary' "$out"

# 3. two blocks with the same values are one dark theme, written under both
out=$(bash "$EXPORT" "$P/twin" 2>&1); rc=$?
is "export-tokens.sh derives two dark selectors with the same values" "$rc" 0
[ "$rc" -eq 0 ] || printf '%s\n' "$out" | sed 's/^/# /'
t "tokens.css writes the [data-theme=\"dark\"] block" '^\[data-theme="dark"\] \{$' "$(cat "$P/twin/tokens.css")"
t "tokens.css writes the .dark block" '^\.dark \{$' "$(cat "$P/twin/tokens.css")"
out=$(bash "$EXPORT" "$P/twin" --check 2>&1); rc=$?
is "--check passes after deriving two dark selectors" "$rc" 0

# 4. two dark blocks with different values, or a block petals cannot read,
#    are refused and named
out=$(bash "$EXPORT" "$P/clash" 2>&1); rc=$?
is "export-tokens.sh refuses two dark blocks with different values" "$rc" 2
t "the refusal names both selectors" '^FATAL: .*\[data-theme="dark"\].*\.dark|^FATAL: .*\.dark.*\[data-theme="dark"\]' "$out"
n "the refusal writes no tokens.css" 'tokens\.css' "$(ls "$P/clash")"
out=$(bash "$EXPORT" "$P/open" 2>&1); rc=$?
is "export-tokens.sh refuses a dark block it cannot read" "$rc" 2
t "the refusal says what it cannot read" '^FATAL: .*brace' "$out"
n "the messages carry no em dash" '—' "$(bash "$EXPORT" "$P/clash" 2>&1; bash "$EXPORT" "$P/open" 2>&1)"

# 5. a page under the brand's own dark selector is judged in the dark theme
cat > "$P/page.css" <<'CSS'
:root { --ink: #1F2A24; }
.dark { --ink: #ECE8DC; }
.dark .card { color: var(--ink); background: #F6F3EA; }
.dark .pane { box-shadow: 0 1px 2px rgba(31, 42, 36, 0.08); }
.dark .lit { box-shadow: 0 1px 2px rgba(5, 8, 6, 0.4); }
.rest { box-shadow: 0 1px 2px rgba(31, 42, 36, 0.08); }
CSS
out=$(bash "$CHECK" "$P/page.css" --brand "$P/dot" 2>&1)
t "check.sh judges the page by the .dark brand" '^Result: ' "$out"
t "a .dark rule's contrast is judged in the dark theme" 'ERROR \[color\] line 3: #ECE8DC on #F6F3EA .*\(dark theme\)' "$out"
t "the night shadow rule sees .dark as dark" 'WARNING \[surface\] line 4: box-shadow in the dark theme is shadow-rest.s light recipe' "$out"
n "the night recipe under .dark passes" 'line 5:' "$out"
n "the light recipe outside .dark passes" 'line 6:' "$out"

# a selector that is only this brand's own: the check learns it from colors.md
sed 's/\.dark/.theme-ink/' "$P/page.css" > "$P/ink.css"
out=$(bash "$CHECK" "$P/ink.css" --brand "$P/ink" 2>&1)
t "check.sh judges the page by the .theme-ink brand" '^Result: ' "$out"
t "a rule under the brand's own selector is judged in the dark theme" 'ERROR \[color\] line 3: #ECE8DC on #F6F3EA .*\(dark theme\)' "$out"
t "the night shadow rule sees the brand's own selector as dark" 'WARNING \[surface\] line 4: box-shadow in the dark theme is shadow-rest.s light recipe' "$out"
n "the night recipe under the brand's own selector passes" 'line 5:' "$out"
n "the light recipe outside the brand's own selector passes" 'line 6:' "$out"
out=$(bash "$CHECK" "$P/ink.css" --brand "$P/dot" 2>&1)
t "check.sh judges the .theme-ink page by the .dark brand" '^Result: ' "$out"
n "a selector the brand never names is not read as dark" 'in the dark theme|\(dark theme\)' "$out"

# the prefers-color-scheme brand: its night rule holds under the media query
cat > "$P/media.css" <<'CSS'
@media (prefers-color-scheme: dark) {
  .pane { box-shadow: 0 1px 2px rgba(31, 42, 36, 0.08); }
}
CSS
out=$(bash "$CHECK" "$P/media.css" --brand "$P/media" 2>&1)
t "check.sh judges the page by the media-query brand" '^Result: ' "$out"
t "the night shadow rule holds for the media-query brand" 'WARNING \[surface\] line 2: box-shadow in the dark theme is shadow-rest.s light recipe' "$out"

# 6. a brand whose dark theme cannot be read: the rest is still judged
out=$(bash "$CHECK" "$P/page.css" --brand "$P/clash" 2>&1)
t "check.sh still judges the page by the brand with two dark blocks" '^Result: ' "$out"
t "check.sh warns that the brand's dark theme was not read, naming both selectors" 'WARNING .*dark theme.*not.*\[data-theme="dark"\].*\.dark|WARNING .*dark theme.*not.*\.dark.*\[data-theme="dark"\]' "$out"
t "the warning names what was not judged" 'WARNING .*night shadow' "$out"
t "the rest of the page is still judged" 'ERROR \[color\] line 3: ' "$out"
out=$(bash "$CHECK" "$P/page.css" --brand "$P/open" 2>&1)
t "check.sh still judges the page by the brand with an open block" '^Result: ' "$out"
t "check.sh warns that it cannot read the open block" 'WARNING .*dark theme.*brace' "$out"
n "the warnings carry no em dash" '—' "$out$(bash "$CHECK" "$P/page.css" --brand "$P/clash" 2>&1)"

# 7. the plotplot brands keep their [data-theme="dark"] block. v1.15.0's
#    committed tokens are a derivation, so it derives them byte for byte;
#    the older releases committed hand-written ones.
for b in test/fixtures/brand-plotplot-v*/.brand; do
  v=$(basename "$(dirname "$b")")
  cp -R "$b" "$P/$v"
  out=$(bash "$EXPORT" "$P/$v" 2>&1); rc=$?
  is "export-tokens.sh derives $v" "$rc" 0
  t "$v writes its dark tokens under [data-theme=\"dark\"]" '^\[data-theme="dark"\] \{
  --pp-' "$(dark_of "$P/$v/tokens.css" '[data-theme="dark"] {')"
done
V15=test/fixtures/brand-plotplot-v1.15.0/.brand
if cmp -s "$V15/tokens.css" "$P/brand-plotplot-v1.15.0/tokens.css" && cmp -s "$V15/tokens.json" "$P/brand-plotplot-v1.15.0/tokens.json"; then
  echo "ok - brand-plotplot-v1.15.0 derives its committed tokens.css and tokens.json byte for byte"
else
  echo "not ok - brand-plotplot-v1.15.0 derives its committed tokens.css and tokens.json byte for byte"; fails=$((fails+1))
fi

echo; echo "$fails failure(s)"; exit "$fails"
