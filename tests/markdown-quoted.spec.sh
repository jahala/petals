#!/usr/bin/env bash
# Spec: in a markdown file, fenced code blocks and inline code are quoted
# output, as <pre> and <code> are in a page: no rule judges them. Prose around
# them is still judged, on its own line numbers. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.11.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
cat > "$PROBE/doc.md" <<'MD'
# A guide

```
ERROR [color] line 3: #3B82F6 is not in the palette.
Result: FAIL — 1 error(s) to fix.
<a href="#">Get started</a>
```

Add the trailer `Petals-allow: <rule> <reason>` to the commit.
We supercharge your brand.
The accent is #3B82F6.
MD
out=$(bash "$SCRIPT" "$PROBE/doc.md" --brand "$BRAND" --product petals 2>&1)
n "a colour in a fenced block is not judged" 'line 4:' "$out"
n "an em dash in a fenced block is not judged" 'line 5:' "$out"
n "a dead link in a fenced block is not judged" 'line 6:' "$out"
n "inline code is not judged" 'line 9:' "$out"
t "prose after the fence is judged on its own line" 'ERROR \[voice\] line 10: "supercharge" is a forbidden term' "$out"
t "a colour in prose is judged" 'ERROR \[color\] line 11: #3B82F6 is not in the palette' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
