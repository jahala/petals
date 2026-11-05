#!/usr/bin/env bash
# Spec: when voice.md bans em dashes, check.sh reports them: an error in copy,
# a warning in a comment (copied comments are how they spread), nothing in
# quoted output (<pre>, <code>). Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BANS=test/fixtures/brand-plotplot-v1.9.0/.brand
ALLOWS=test/fixtures/brand-plotplot-v2.0.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }

# known case: the reference page before plotplot 6222d05, two dashes in CSS comments
out=$(bash "$SCRIPT" test/fixtures/voice/reference-product-7966871.html --brand "$BANS" 2>&1)
t "a dash in a CSS comment warns (line 34)" 'WARNING \[voice\] line 34: em dash in a comment' "$out"
t "a dash in a CSS comment warns (line 59)" 'WARNING \[voice\] line 59: em dash in a comment' "$out"
n "comment dashes are not errors" 'ERROR \[voice\].*em dash' "$out"

PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
cat > "$PROBE/page.html" <<'HTML'
<p>Fast — and calm.</p>
<p>Also &mdash; here.</p>
<!-- a note — in markup -->
<pre>
$ tool run — quoted output
</pre>
<p>Run <code>a — b</code> to see.</p>
HTML
out=$(bash "$SCRIPT" "$PROBE/page.html" --brand "$BANS" 2>&1)
t "a dash in copy is an error" 'ERROR \[voice\] line 1: em dash in copy' "$out"
t "an &mdash; entity in copy is an error" 'ERROR \[voice\] line 2: em dash in copy' "$out"
t "a dash in an HTML comment warns" 'WARNING \[voice\] line 3: em dash in a comment' "$out"
n "quoted output in a pre block is skipped" 'line 5:.*em dash' "$out"
n "inline code is skipped" 'line 7:.*em dash' "$out"
out=$(bash "$SCRIPT" "$PROBE/page.html" --brand "$ALLOWS" 2>&1)
n "a brand that does not ban em dashes gets no dash finding" 'em dash' "$out"
# a product with no voice layer of its own still gets the umbrella's voice rules
printf '<p>We supercharge your brand.</p>\n' > "$PROBE/terms.html"
out=$(bash "$SCRIPT" "$PROBE/terms.html" --brand "$BANS" --product petals 2>&1)
t "forbidden terms are judged for a product without a voice layer" 'ERROR \[voice\] line 1: "supercharge" is a forbidden term' "$out"
n "no unbound-variable noise" 'unbound variable' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
