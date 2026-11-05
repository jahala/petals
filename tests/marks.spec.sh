#!/usr/bin/env bash
# Spec: petals/scripts/marks.py checks the garden's marks and derives their
# night files and tiles byte for byte as plotplot's marks.py did at v1.9.0,
# reading the beds and the drawing rules from the brand. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
MARKS=petals/scripts/marks.py
EXP=test/fixtures/marks/expected
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
fresh() { rm -rf "$P/b"; cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$P/b"; }
fresh
out=$(python3 -I "$MARKS" --brand "$P/b" --check 2>&1); rc=$?
[ "$rc" -eq 0 ] && [ "$out" = "$(cat "$EXP/check.txt")" ] && echo "ok - --check at v1.9.0 prints plotplot's message exactly" || { echo "not ok - --check at v1.9.0 prints plotplot's message exactly (rc $rc): $out"; fails=$((fails+1)); }
for b in plotplot copeca tend umbel; do
  for n in "" "-night"; do
    flag=""; [ -n "$n" ] && flag="--night"
    python3 -I "$MARKS" --brand "$P/b" tile "$b" $flag > "$P/tile.svg" 2>&1
    cmp -s "$P/tile.svg" "$EXP/tile-$b$n.svg" && echo "ok - tile $b $flag is byte-identical" || { echo "not ok - tile $b $flag is byte-identical"; fails=$((fails+1)); }
  done
done
# write mode regenerates every night file exactly as committed
find "$P/b" -name '*-mark-night.svg' -exec rm {} +
python3 -I "$MARKS" --brand "$P/b" >/dev/null 2>&1
same=1
while IFS= read -r f; do cmp -s "$f" "$P/b/${f#test/fixtures/brand-plotplot-v1.9.0/.brand/}" || { same=0; echo "# differs: $f"; }; done < <(find test/fixtures/brand-plotplot-v1.9.0/.brand -name '*-mark-night.svg')
[ "$same" = 1 ] && echo "ok - regenerated night files equal the committed ones" || { echo "not ok - regenerated night files equal the committed ones"; fails=$((fails+1)); }
# a night file edited by hand fails, named
fresh; sed -i '' 's/#1C1610/#1C1611/' "$P/b/products/tend/assets/tend-mark-night.svg"
out=$(python3 -I "$MARKS" --brand "$P/b" --check 2>&1); rc=$?
[ "$rc" -eq 1 ] && echo "ok - a hand-edited night file fails --check" || { echo "not ok - a hand-edited night file fails --check (rc $rc)"; fails=$((fails+1)); }
t "the hand-edited night file is named" '^tend: .*tend-mark-night\.svg is not derived' "$out"
# a third colour in a tiled mark breaks the rules
fresh; perl -0pi -e 's/fill="#1C1610"/fill="#357E2C"/' "$P/b/products/tend/assets/tend-mark.svg"
out=$(python3 -I "$MARKS" --brand "$P/b" --check 2>&1)
t "a third colour in a tiled mark is named" '^tend: inks outside the tile and its ink' "$out"
# the beds come from the brand, not a list in the script
fresh; rm -rf "$P/b/products/well"
out=$(python3 -I "$MARKS" --brand "$P/b" --check 2>&1)
t "the bed count follows the brand's product layers" 'marks: 13 beds, rules hold' "$out"
# the line weight comes from DESIGN.md section 7
fresh; sed -i '' 's/Lines are 2 units/Lines are 3 units/' "$P/b/DESIGN.md"
out=$(python3 -I "$MARKS" --brand "$P/b" --check 2>&1)
t "the stroke rule is read from DESIGN.md" 'stroke widths other than 3' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
