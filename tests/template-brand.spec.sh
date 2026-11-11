#!/usr/bin/env bash
# Spec: a brand filled in from petals' templates is a brand petals' scripts
# read, whatever its token prefix. The fixture (test/fixtures/brand-template)
# is the seven templates filled in for larch, a fictional brand whose prefix
# is --larch-. The templates must write the headings, table columns and CSS
# blocks the scripts parse; export-tokens.sh must derive every token from
# them; check.sh must judge a page by them; and review.sh's index must use
# the brand's own prefix. A brand that declares no single prefix is refused,
# never guessed. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
EXPORT=petals/scripts/export-tokens.sh
CHECK=petals/scripts/check.sh
REVIEW="$PWD/petals/scripts/review.sh"
FX=test/fixtures/brand-template/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1: wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1: did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
is() { if [ "$2" = "$3" ]; then echo "ok - $1"; else echo "not ok - $1: wanted $3, got $2"; fails=$((fails+1)); fi }
# replace text in a file, the same on macOS and Linux (sed -i differs between them)
subst() { python3 -I -c 'import sys; p, a, b = sys.argv[1:]; s = open(p).read(); assert a in s, a; open(p, "w").write(s.replace(a, b))' "$1" "$2" "$3"; }

P=$(mktemp -d)
mkdir -p "$P/fakebin" "$P/proj/drafts"
printf '#!/bin/sh\nfor a in "$@"; do mv "$a" "%s/.t-$(basename "$a")"; done\n' "$P" > "$P/fakebin/trash"; chmod +x "$P/fakebin/trash"
cleanup() { (cd "$P/proj" && PATH="$P/fakebin:$PATH" bash "$REVIEW" --stop >/dev/null 2>&1); rm -rf "$P"; }
trap cleanup EXIT

# 1. the fixture is the templates filled in: every heading, table header and
#    CSS custom property a template writes is in the filled file
python3 -I - petals/templates "$FX" <<'PY'
import os, re, sys
tdir, fdir = sys.argv[1:3]
PH = re.compile(r"\{\{[A-Z0-9_]+\}\}")
fails = 0

def norm(line):
    s = line.strip()
    if s.startswith("|"):
        return "|".join(c.strip() for c in s.strip("|").split("|"))
    return " ".join(s.split())

def structure(text):
    lines = text.split("\n")
    out, fence = [], False
    for i, line in enumerate(lines):
        if line.lstrip().startswith("```"):
            fence = not fence
            continue
        if fence:
            if re.match(r"\s*--[^:]+:", line):
                out.append(norm(line))
            continue
        nxt = lines[i + 1] if i + 1 < len(lines) else ""
        if re.match(r"#{1,6}\s", line):
            out.append(norm(line))
        elif line.lstrip().startswith("|") and re.fullmatch(r"\s*\|[\s:|-]+\|\s*", nxt):
            out.append(norm(line))
    return out

def pattern(line):
    return re.compile(".+?".join(re.escape(p) for p in PH.split(line)) + "$")

def ok(cond, msg, detail=()):
    global fails
    print(("ok - " if cond else "not ok - ") + msg)
    for d in detail:
        print("# " + d)
    if not cond:
        fails += 1

for name in ["DESIGN.md", "colors.md", "components.md", "identity.md", "layout.md", "typography.md", "voice.md"]:
    tmpl = open(os.path.join(tdir, name), encoding="utf-8").read()
    filled = open(os.path.join(fdir, name), encoding="utf-8").read()
    have = structure(filled)
    missing = [s for s in structure(tmpl) if not any(pattern(s).match(h) for h in have)]
    ok(not missing, "templates/%s: the filled file has every heading, table header and CSS property it writes" % name,
       ["missing: " + m for m in missing])
    ok("\u2014" not in tmpl, "templates/%s carries no em dash" % name)
    ok(not PH.search(filled), "the filled %s leaves no placeholder" % name, PH.findall(filled))

colors = open(os.path.join(tdir, "colors.md"), encoding="utf-8").read()
props = [l.strip() for b in re.findall(r"```css\n(.*?)```", colors, flags=re.S) for l in b.split("\n") if l.strip().startswith("--")]
ok(props and all(p.startswith("--{{PREFIX}}-") for p in props),
   "templates/colors.md declares every custom property under the brand's {{PREFIX}}",
   [p for p in props if not p.startswith("--{{PREFIX}}-")])
ok(re.search(r'^\[data-theme="dark"\] \{', colors, flags=re.M) is not None,
   'templates/colors.md writes the dark theme as a [data-theme="dark"] block')
sys.exit(fails)
PY
fails=$((fails + $?))

# 2. export-tokens.sh derives the brand: every colour in light and dark, the
#    fonts, spacing, layout, radius, strokes, shadows and motion
cp -R "$FX" "$P/larch"
out=$(bash "$EXPORT" "$P/larch" 2>&1); rc=$?
is "export-tokens.sh derives the larch brand" "$rc" 0
[ "$rc" -eq 0 ] || printf '%s\n' "$out" | sed 's/^/# /'
css=$(cat "$P/larch/tokens.css" 2>/dev/null)
python3 -I - "$FX/colors.md" "$P/larch/tokens.css" "$P/larch/tokens.json" <<'PY'
import json, re, sys
md, css_path, json_path = sys.argv[1:4]
fails = 0
def blocks(text, sel):
    return dict(m for b in re.findall(sel + r"\s*\{(.*?)\}", text, flags=re.S)
                for m in re.findall(r"(--[\w-]+)\s*:\s*(#[0-9A-Fa-f]{6})\s*;", b))
src = "".join(re.findall(r"```css\n(.*?)```", open(md, encoding="utf-8").read(), flags=re.S))
try:
    css = open(css_path, encoding="utf-8").read()
    doc = json.load(open(json_path, encoding="utf-8"))
except (OSError, ValueError):
    css, doc = "", {}
for theme, sel in (("light", r":root"), ("dark", r'\[data-theme="dark"\]')):
    want, got = blocks(src, sel), blocks(css, sel)
    missing = ["%s: %s" % kv for kv in want.items() if got.get(kv[0]) != kv[1]]
    ok = bool(want) and not missing
    print(("ok - " if ok else "not ok - ") + "every %s colour colors.md declares is a token with its value (%d)" % (theme, len(want)))
    for m in missing:
        print("# missing " + m)
    fails += 0 if ok else 1
ok = doc.get("color", {}).get("primary", {}).get("$value") == "#2F6B4F" and doc.get("dark", {}).get("color", {}).get("primary", {}).get("$value") == "#7FC29B"
print(("ok - " if ok else "not ok - ") + "tokens.json carries the colours in both themes")
fails += 0 if ok else 1
sys.exit(fails)
PY
fails=$((fails + $?))
t "the heading font is a token" "--larch-font-heading: 'Fraunces', Georgia, serif;" "$css"
t "the body font is a token" "--larch-font-body: 'Inter', system-ui, sans-serif;" "$css"
t "the code font is a token" "--larch-font-code: 'Space Mono', ui-monospace, monospace;" "$css"
t "a spacing step is a token" '--larch-space-sm: 16px;' "$css"
t "the container width is a token" '--larch-container-max: 1120px;' "$css"
t "the gutter is a token" '--larch-gutter: 24px;' "$css"
t "a named breakpoint is a token" '--larch-breakpoint-wide: 1024px;' "$css"
t "a radius is a token" '--larch-radius-sm: 4px;' "$css"
t "a stroke is a token" '--larch-stroke-hairline: 1px;' "$css"
t "a shadow recipe is a token" '--larch-shadow-lift: 0 4px 16px rgba\(31, 42, 36, 0\.12\);' "$css"
t "the easing is a token" '--larch-ease: cubic-bezier\(0\.2, 0, 0, 1\);' "$css"
t "a duration is a token" '--larch-dur-micro: 0\.15s;' "$css"
t "the header names the brand from identity.md" '^/\* larch design tokens' "$css"
n "no token carries plotplot's prefix" '--pp-' "$css"
out=$(bash "$EXPORT" "$P/larch" --check 2>&1); rc=$?
is "--check passes after deriving" "$rc" 0

# 3. check.sh judges a page by the larch brand: palette, documented contrast
#    pairs and the faces' weights and styles
cat > "$P/probe.css" <<'CSS'
.ok { color: #1F2A24; background: #F6F3EA; }
.off { color: #123456; }
.moss { color: #628C6C; background: #F6F3EA; }
.warn { color: #9A6A12; background: #F6F3EA; }
.heavy { font-family: var(--larch-font-heading); font-weight: 800; }
.slant { font-family: 'Inter', sans-serif; font-style: italic; }
.fine { font-family: var(--larch-font-heading); font-weight: 600; }
CSS
out=$(bash "$CHECK" "$P/probe.css" --brand "$FX" 2>&1); rc=$?
is "the probe page fails the check" "$rc" 1
n "an on-palette reading pair passes" 'line 1:' "$out"
t "an off-palette hex is an error" 'ERROR \[color\] line 2: #123456 is not in the palette' "$out"
t "a documented decorative pair set as words is an error" 'ERROR \[color\] line 3: #628C6C on #F6F3EA .*documented decorative-only pair' "$out"
n "a documented labels pair at 4.26:1 meets its minimum" 'line 4:' "$out"
t "a weight the heading face does not ship is an error" 'ERROR \[typography\] line 5: "Fraunces" has no weight 800' "$out"
t "an italic the body face does not ship is an error" 'ERROR \[typography\] line 6: "Inter" has no italic' "$out"
n "a weight the face ships passes" 'line 7:' "$out"

# 4. check.sh's [tokens] warnings compare tokens.css with the markdown under
#    the brand's prefix
printf '.x { color: #1F2A24; background: #F6F3EA; }\n' > "$P/clean.css"
out=$(bash "$CHECK" "$P/clean.css" --brand "$P/larch" 2>&1)
t "tokens in step with the markdown pass" '^Result: PASS' "$out"
n "tokens in step with the markdown raise no [tokens] warning" '\[tokens\]' "$out"
cp -R "$P/larch" "$P/stale"
subst "$P/stale/tokens.css" '--larch-primary: #2F6B4F;' '--larch-primary: #2F6B50;'
subst "$P/stale/tokens.css" "--larch-font-heading: 'Fraunces'" "--larch-font-heading: 'Inter'"
out=$(bash "$CHECK" "$P/clean.css" --brand "$P/stale" 2>&1)
t "a stale colour token is named under the brand's prefix" 'WARNING \[tokens\] tokens.css --larch-primary: #2F6B50 does not match colors.md: #2F6B4F' "$out"
t "a stale font token is named under the brand's prefix" 'WARNING \[tokens\] tokens.css --larch-font-heading: Inter does not match typography.md: Fraunces' "$out"

# 5. a brand that declares no single prefix is refused, never guessed
cp -R "$P/larch" "$P/mixed"
subst "$P/mixed/colors.md" '--larch-info: #3B6A8A;' '--color-info: #3B6A8A;'
out=$(bash "$EXPORT" "$P/mixed" 2>&1); rc=$?
is "export-tokens.sh exits 2 when colors.md mixes prefixes" "$rc" 2
t "it names the prefixes it found" 'FATAL: .*--larch-.*--color-' "$out"
out=$(bash "$CHECK" "$P/clean.css" --brand "$P/mixed" 2>&1); rc=$?
is "check.sh exits 3, could not judge, when colors.md mixes prefixes" "$rc" 3
t "check.sh says why it could not judge" 'could not judge.*--larch-.*--color-' "$out"

# 6. review.sh's index page is styled with the brand's own tokens
cp -R "$P/larch" "$P/proj/.brand"
printf '<!doctype html><title>plan</title><h1>The plan</h1>\n' > "$P/proj/drafts/plan.html"
out=$(cd "$P/proj" && PATH="$P/fakebin:$PATH" bash "$REVIEW" drafts/plan.html --no-open 2>&1); rc=$?
is "review.sh starts on the larch brand" "$rc" 0
index=$(cat "$P/proj/.petals-review/index.html" 2>/dev/null)
t "the index uses the brand's prefix" 'var\(--larch-bg\)' "$index"
n "the index carries no other prefix" 'var\(--pp-' "$index"
undefined=$(printf '%s\n' "$index" | grep -oE 'var\(--[a-z0-9-]+\)' | sed -E 's/var\((.*)\)/\1/' | sort -u | while read -r v; do grep -q -e "^  $v:" "$P/proj/.brand/tokens.css" || echo "$v"; done)
if [ -n "$index" ] && [ -z "$undefined" ]; then echo "ok - every token the index uses is one the brand defines"
else echo "not ok - every token the index uses is one the brand defines"; printf '# undefined: %s\n' $undefined; fails=$((fails+1)); fi
out=$(bash "$CHECK" "$P/proj/.petals-review/index.html" --brand "$P/proj/.brand" 2>&1)
t "the index passes petals check against the larch brand" '^Result: PASS' "$out"

echo; echo "$fails failure(s)"; exit "$fails"
