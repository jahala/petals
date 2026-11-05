#!/usr/bin/env bash
# Spec: a file has a stage. Mockup paths are declared in .petalsrc and every
# other file is production. Content-truth findings (placeholders, dummy
# contacts, dead links) are notes in a mockup and errors in production; brand
# rules are the same in both. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT="$PWD/petals/scripts/check.sh"
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
mkdir -p "$P/proj/docs/designs" "$P/proj/public"
cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$P/proj/.brand"
cat > "$P/proj/.petalsrc" <<'RC'
brand:
  source: https://github.com/jahala/plotplot.git
  version: v1.9.0
  overrides: {}
stages:
  mockup:
    - docs/designs/**
RC
cat > "$P/page.html" <<'HTML'
<p>Lorem ipsum dolor sit amet.</p>
<p>Call us on 555-0142 or write to hello@example.com.</p>
<a href="#">Read the case study</a>
<p style="color:#3B82F6">An off-palette word.</p>
HTML
cp "$P/page.html" "$P/proj/docs/designs/page.html"; cp "$P/page.html" "$P/proj/public/page.html"
mock=$(cd "$P/proj" && bash "$SCRIPT" docs/designs/page.html 2>&1)
prod=$(cd "$P/proj" && bash "$SCRIPT" public/page.html 2>&1)
t "a placeholder in production is an error" 'ERROR \[content\] line 1: .*placeholder' "$prod"
t "a dummy phone number in production is an error" 'ERROR \[content\] line 2: .*555-0142' "$prod"
t "a dummy address in production is an error" 'ERROR \[content\] line 2: .*example\.com' "$prod"
t "a dead link in production is an error" 'ERROR \[content\] line 3: .*href="#"' "$prod"
t "the same placeholder under a mockup path is a note" 'NOTE \[content\] line 1: .*placeholder' "$mock"
n "content findings under a mockup path are not errors" 'ERROR \[content\]' "$mock"
t "brand rules hold in a mockup" 'ERROR \[color\] line 4: #3B82F6' "$mock"
t "brand rules hold in production" 'ERROR \[color\] line 4: #3B82F6' "$prod"
t "the summary counts notes" 'Content: +0 error\(s\), 0 warning\(s\), [1-9][0-9]* note\(s\)' "$mock"
mkdir -p "$P/proj/site"; cp "$P/page.html" "$P/proj/site/page.html"
other=$(cd "$P/proj" && bash "$SCRIPT" site/page.html 2>&1)
t "a file in no declared stage is production" 'ERROR \[content\] line 1' "$other"
forced=$(cd "$P/proj" && bash "$SCRIPT" public/page.html --stage mockup 2>&1)
t "--stage mockup overrides the configured stage" 'NOTE \[content\] line 1' "$forced"
sarif=$(cd "$P/proj" && bash "$SCRIPT" docs/designs/page.html --format sarif 2>&1)
t "a mockup content finding is a SARIF note" '"ruleId":"content/placeholder","level":"note"' "$sarif"
printf '<pre>lorem ipsum in quoted output</pre>\n<!-- lorem ipsum in a comment -->\n<p>Real copy.</p>\n' > "$P/quoted.html"
q=$(bash "$SCRIPT" "$P/quoted.html" --brand test/fixtures/brand-plotplot-v1.9.0/.brand 2>&1)
n "quoted output and comments are not copy" '\[content\]' "$q"
echo; echo "$fails failure(s)"; exit "$fails"
