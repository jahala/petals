#!/usr/bin/env bash
# Spec: `petals gate` judges the UI files a change touches and writes one
# SARIF 2.1.0 log. With --base <ref> the change is base...HEAD; without it,
# the working tree against HEAD (untracked files included). The config and
# the brand come from the base, never from the change (issue #4). Prints TAP.
cd "$(dirname "$0")/.." || exit 1
PETALS="$PWD/petals/bin/petals"
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
R="$P/repo"; mkdir -p "$R"
g() { git -C "$R" -c user.name=t -c user.email=t@t "$@"; }
g init -q -b main
cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$R/.brand"
printf 'brand:\n  source: https://github.com/jahala/plotplot.git\n  version: v1.9.0\n  overrides: {}\nstages:\n  mockup:\n    - docs/designs/**\n' > "$R/.petalsrc"
mkdir -p "$R/public" "$R/docs/designs" "$R/src"
echo '<p>Fine words.</p>' > "$R/public/ok.html"
g add -A && g commit -qm base
# a change: a production page with an off-palette colour and a placeholder,
# a mockup page with a placeholder, a non-UI file, and an attempt to loosen
# the rules from inside the change (a mockup glob for public/, and the
# off-palette colour added to the brand)
printf '<p style="color:#3B82F6">Lorem ipsum.</p>\n' > "$R/public/page.html"
printf '<p>Lorem ipsum in a draft.</p>\n' > "$R/docs/designs/draft.html"
echo 'print("not ui")' > "$R/src/tool.py"
perl -pi -e 's#^(    - docs/designs/\*\*)$#$1\n    - public/**#' "$R/.petalsrc"
grep -q 'public/\*\*' "$R/.petalsrc" || { echo "not ok - the spec could not loosen the change's .petalsrc"; exit 1; }
printf '\n| Loosened | #3B82F6 | added by the change |\n' >> "$R/.brand/colors.md"
(cd "$R" && "$PETALS" gate --format sarif) > "$P/wt.sarif" 2>"$P/wt.err"
python3 -I - "$P/wt.sarif" <<'PY' > "$P/wt.txt"
import json, sys
d = json.load(open(sys.argv[1]))
assert d["version"] == "2.1.0" and len(d["runs"]) == 1
for r in d["runs"][0]["results"]:
    print(r["level"], r["ruleId"], r["locations"][0]["physicalLocation"]["artifactLocation"]["uri"])
PY
wt=$(cat "$P/wt.txt")
t "working tree: stdout is one SARIF log with one run" 'content/placeholder' "$wt"
t "working tree: an untracked production page is judged" 'error color/off-palette public/page.html' "$wt"
t "working tree: production content is an error" 'error content/placeholder public/page.html' "$wt"
t "working tree: mockup content is a note" 'note content/placeholder docs/designs/draft.html' "$wt"
n "working tree: a non-UI file is not judged" 'src/tool.py' "$wt"
n "working tree: an unchanged file is not judged" 'public/ok.html' "$wt"
n "the change cannot declare its own page a mockup" 'note content/placeholder public/page.html' "$wt"
g add -A && g commit -qm change
(cd "$R" && "$PETALS" gate --base main~1 --format sarif) > "$P/pr.sarif" 2>"$P/pr.err"
pr=$(python3 -I -c 'import json,sys; [print(r["level"], r["ruleId"], r["locations"][0]["physicalLocation"]["artifactLocation"]["uri"]) for r in json.load(open(sys.argv[1]))["runs"][0]["results"]]' "$P/pr.sarif")
t "--base: the committed change is judged" 'error color/off-palette public/page.html' "$pr"
t "--base: the base's brand is used, so the colour the change added is still off-palette" 'error color/off-palette' "$pr"
t "--base: the base's stages are used" 'error content/placeholder public/page.html' "$pr"
(cd "$R" && "$PETALS" gate --base main) > "$P/none.sarif" 2>/dev/null
t "--base with nothing changed is an empty, valid log" '"results":\[\]' "$(tr -d ' \n' < "$P/none.sarif")"
[ ! -s "$P/wt.err" ] && echo "ok - nothing on stderr" || { echo "not ok - nothing on stderr: $(head -2 "$P/wt.err")"; fails=$((fails+1)); }
# a change cannot give itself a product context the base does not have
# (another product's accent is only a warning inside that product's UI)
printf '<p style="color:#98D98D">tend green.</p>\n' > "$R/public/accent.html"
printf 'brand:\n  product: petals\n' >> "$R/.petalsrc"
g add -A && g commit -qm "adds a product"
pa=$(cd "$R" && "$PETALS" gate --base main~1 --format sarif 2>/dev/null | python3 -I -c 'import json,sys; [print(r["ruleId"], r["locations"][0]["physicalLocation"]["artifactLocation"]["uri"]) for r in json.load(sys.stdin)["runs"][0]["results"]]')
n "the change cannot add a product context the base lacks" 'color/product-accent public/accent.html' "$pa"
# a product repo: the umbrella's files are an ignored cache, the product layer is committed
Q="$P/product"; mkdir -p "$Q"
q() { git -C "$Q" -c user.name=t -c user.email=t@t "$@"; }
q init -q -b main
cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$Q/.brand"
printf '/.brand/*\n!/.brand/products/\n/.brand/products/*\n!/.brand/products/petals/\n' > "$Q/.gitignore"
mkdir -p "$Q/.brand/products/petals" && printf '# petals: colour delta\n' > "$Q/.brand/products/petals/colors.md"
printf 'brand:\n  source: https://github.com/jahala/plotplot.git\n  version: v1.9.0\n  product: petals\n' > "$Q/.petalsrc"
q add -A && q commit -qm base
printf '<p style="color:#3B82F6">x</p>\n<p style="color:#357E2C">y</p>\n' > "$Q/page.html"
q add -A && q commit -qm change
pq=$(cd "$Q" && "$PETALS" gate --base main~1 --format sarif 2>"$P/q.err" | python3 -I -c 'import json,sys; [print(r["ruleId"], r["locations"][0]["physicalLocation"].get("region",{}).get("startLine")) for r in json.load(sys.stdin)["runs"][0]["results"]]')
t "a product repo: an off-palette colour fails" 'color/off-palette 1' "$pq"
n "a product repo: the umbrella's palette is read, so its green passes" 'color/off-palette 2' "$pq"
echo; echo "$fails failure(s)"; exit "$fails"
