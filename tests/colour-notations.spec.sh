#!/usr/bin/env bash
# Spec: check.sh judges colours written as oklch(), oklab(), rgb()/rgba() and
# hsl()/hsla() the way it judges hex (issue #42):
#   - an off-palette colour in each notation is an error with a nearest
#     palette suggestion;
#   - each notation of a palette colour passes, in the space and the comma
#     syntax, with alpha and with percentages;
#   - a contrast pair written in these notations is judged, through var()
#     and per theme as well;
#   - a colour outside sRGB gets its own message and no suggestion;
#   - a value built from var() or calc() is not judged, nor is quoted output;
#   - the oklch conversion is new-brand.py's, compared on a sweep of inputs,
#     and the hsl conversion matches exact rational arithmetic.
# Prints TAP. Run from the repo root: bash tests/colour-notations.spec.sh
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
GEN=petals/scripts/new-brand.py
BRAND=test/fixtures/brand-template/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1: wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1: did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
OFF='\(#[0-9A-F]{6}\) is not in the palette\. Did you mean #[0-9A-F]{6}'

# 1. off-palette colours in each notation are errors with a suggestion
cat > "$PROBE/off.css" <<'CSS'
.a { color: oklch(0.6 0.2 30); }
.b { color: rgb(222 62 45); }
.c { color: hsl(5 72% 52%); }
.d { color: oklab(0.6 0.17 0.1); }
.e { border-color: rgba(222, 62, 45, 0.5); }
CSS
out=$(bash "$SCRIPT" "$PROBE/off.css" --brand "$BRAND" 2>&1)
t "an off-palette oklch() colour is an error with a suggestion" "ERROR \[color\] line 1: oklch\(0\.6 0\.2 30\) $OFF" "$out"
t "the issue's oklch(0.6 0.2 30) converts to #DE3E2D" 'line 1: oklch\(0\.6 0\.2 30\) \(#DE3E2D\)' "$out"
t "an off-palette rgb() colour is an error with a suggestion" "ERROR \[color\] line 2: rgb\(222 62 45\) $OFF" "$out"
t "an off-palette hsl() colour is an error with a suggestion" "ERROR \[color\] line 3: hsl\(5 72% 52%\) $OFF" "$out"
t "an off-palette oklab() colour is an error with a suggestion" "ERROR \[color\] line 4: oklab\(0\.6 0\.17 0\.1\) $OFF" "$out"
t "an off-palette rgba() colour is an error with a suggestion" "ERROR \[color\] line 5: rgba\(222, 62, 45, 0\.5\) \(#DE3E2D\) is not in the palette" "$out"

# 2. palette colours pass in every notation. Each passing line is followed by
# a near miss that must fail, so a line that passes was read, not ignored.
# Primary #2F6B4F is rgb(47 107 79), hsl(152 38.96% 30.2%) and
# oklch(0.4794 0.078 161.08); the conversions are checked in python below.
cat > "$PROBE/on.css" <<'CSS'
.s1 { color: rgb(47 107 79); }
.s1 { color: rgb(48 107 79); }
.s2 { color: rgb(47, 107, 79); }
.s2 { color: rgb(48, 107, 79); }
.s3 { color: rgba(47, 107, 79, 0.5); }
.s3 { color: rgba(48, 107, 79, 0.5); }
.s4 { color: rgb(47 107 79 / 50%); }
.s4 { color: rgb(48 107 79 / 50%); }
.s5 { color: rgb(18.4314% 41.9608% 30.9804%); }
.s5 { color: rgb(18.9% 41.9608% 30.9804%); }
.s6 { color: hsl(152 38.96% 30.20%); }
.s6 { color: hsl(150 38.96% 30.20%); }
.s7 { color: hsla(152, 38.96%, 30.20%, 0.8); }
.s7 { color: hsla(150, 38.96%, 30.20%, 0.8); }
.s8 { color: hsl(152deg 38.96% 30.2% / 0.8); }
.s8 { color: hsl(150deg 38.96% 30.2% / 0.8); }
.s9 { color: oklch(0.4794 0.0780 161.08); }
.s9 { color: oklch(0.4794 0.0780 162.5); }
.sa { color: oklch(47.94% 0.078 161.08 / 0.5); }
.sa { color: oklch(47.94% 0.078 162.5 / 0.5); }
.sb { color: oklch(0.4794 19.5% 161.08); }
.sb { color: oklch(0.4794 19.5% 162.5); }
.sc { color: oklab(0.4794 -0.0738 0.0253); }
.sc { color: oklab(0.4794 -0.0700 0.0253); }
.sd { color: OKLCH(0.4794 0.0780 161.08); }
.sd { color: OKLCH(0.4794 0.0780 162.5); }
.se { --brand-green: oklch(0.4794 0.0780 161.08); }
.se { --brand-green: oklch(0.4794 0.0780 162.5); }
CSS
out=$(bash "$SCRIPT" "$PROBE/on.css" --brand "$BRAND" 2>&1)
forms="rgb-space rgb-comma rgba-comma rgb-slash-percent rgb-percent hsl-space hsla-comma hsl-deg-slash oklch oklch-percent-alpha oklch-chroma-percent oklab uppercase custom-property"
i=0
for form in $forms; do
  i=$((i+1)); on=$((2*i-1)); miss=$((2*i))
  n "$form: the palette colour passes" "line $on: " "$out"
  t "$form: a near miss is judged" "ERROR \[color\] line $miss: " "$out"
done

# 3. contrast pairs in these notations are judged
cat > "$PROBE/pairs.css" <<'CSS'
.p { color: oklch(0.6801 0.1366 74.73); background: oklch(0.9640 0.0123 91.52); }
.q { color: rgb(214 207 188); background-color: hsl(45 40% 94.12%); }
:root { --ink: oklch(0.2725 0.0189 160.99); --paper: oklch(0.9640 0.0123 91.52); --wash: rgb(214, 207, 188); }
.r { color: var(--ink); background: var(--paper); }
.s { color: var(--wash); background: var(--paper); }
.u { color: rgba(214, 207, 188, 0.5); background: #F6F3EA; }
.v { color: oklch(0.7 0.4 140); background: #F6F3EA; }
CSS
out=$(bash "$SCRIPT" "$PROBE/pairs.css" --brand "$BRAND" 2>&1)
t "a documented decorative pair in oklch is flagged" 'ERROR \[color\] line 1: #C98A1B on #F6F3EA is 2\.65:1, a documented decorative-only pair' "$out"
t "an rgb() on hsl() pair below 3:1 is flagged" 'ERROR \[color\] line 2: #D6CFBC on #F6F3EA is [0-9.]+:1, below the 3\.0:1 labels minimum' "$out"
n "an oklch pair through var() that meets its floor passes" 'line 4: ' "$out"
t "an oklch pair through var() below its floor is flagged" 'ERROR \[color\] line 5: #D6CFBC on #F6F3EA' "$out"
n "a translucent colour is not judged for contrast: its backdrop decides it" 'line 6: .* on ' "$out"
n "a colour outside sRGB is not judged for contrast" 'line 7: .* on ' "$out"

cat > "$PROBE/card.jsx" <<'JSX'
<p style={{ color: "oklch(0.6801 0.1366 74.73)", background: "#F6F3EA" }}>hi</p>
<p style={{ color: "rgb(31 42 36)", backgroundColor: "hsl(45 40% 94.12%)" }}>hi</p>
JSX
out=$(bash "$SCRIPT" "$PROBE/card.jsx" --brand "$BRAND" 2>&1)
t "a JSX inline style pair in oklch is judged" 'ERROR \[color\] line 1: #C98A1B on #F6F3EA is 2\.65:1, a documented decorative-only pair' "$out"
n "a JSX inline style pair that meets its floor passes" 'line 2: ' "$out"

cat > "$PROBE/themes.css" <<'CSS'
:root { --ink: oklch(0.2725 0.0189 160.99); }
[data-theme="dark"] { --ink: oklch(0.9308 0.0166 91.56); }
.card { color: var(--ink); background: oklch(0.9640 0.0123 91.52); }
:root{--y:oklch(0.2725 0.0189 160.99)}[data-theme="dark"]{--y:rgb(236 232 220)}
.m { color: var(--y); background: #F6F3EA; }
CSS
out=$(bash "$SCRIPT" "$PROBE/themes.css" --brand "$BRAND" 2>&1)
t "an oklch dark override is judged in the dark theme" 'ERROR \[color\] line 3: #ECE8DC on #F6F3EA .*\(dark theme\)' "$out"
n "the oklch light value passes in the light theme" 'line 3: #1F2A24 on' "$out"
t "minified oklch and rgb() theme blocks resolve per theme" 'ERROR \[color\] line 5: #ECE8DC on #F6F3EA .*\(dark theme\)' "$out"

# 4. a colour outside sRGB is reported as such, never rounded into the gamut
cat > "$PROBE/gamut.css" <<'CSS'
.g { color: oklch(0.7 0.4 140); }
.h { color: rgb(300 0 0); }
.i { color: hsl(120 150% 50%); }
.j { color: oklab(0.5 0.4 0.4); }
CSS
out=$(bash "$SCRIPT" "$PROBE/gamut.css" --brand "$BRAND" 2>&1)
t "an oklch() colour outside sRGB has its own message" 'ERROR \[color\] line 1: oklch\(0\.7 0\.4 140\) is outside sRGB' "$out"
t "an rgb() channel above 255 is outside sRGB" 'ERROR \[color\] line 2: rgb\(300 0 0\) is outside sRGB' "$out"
t "an hsl() saturation above 100% is outside sRGB" 'ERROR \[color\] line 3: hsl\(120 150% 50%\) is outside sRGB' "$out"
t "an oklab() colour outside sRGB has its own message" 'ERROR \[color\] line 4: oklab\(0\.5 0\.4 0\.4\) is outside sRGB' "$out"
n "a colour outside sRGB gets no suggestion" 'outside sRGB.*Did you mean' "$out"
sarif=$(bash "$SCRIPT" "$PROBE/gamut.css" --brand "$BRAND" --format sarif 2>&1)
t "SARIF files a colour outside sRGB under color/off-palette" '"ruleId":"color/off-palette","level":"error","message":\{"text":"oklch\(0\.7 0\.4 140\) is outside sRGB' "$sarif"

# 4b. a shadow may use a tint the Shadow Recipes section names, though
# colors.md does not hold it; anywhere else that tint is off the palette.
# The family brand names a night tint, rgba(8, 6, 4, ...), only there.
cat > "$PROBE/shadows.css" <<'CSS'
:root { --pp-shadow-lift: 0 2px 4px rgba(8,6,4,0.3), 0 14px 32px rgba(8,6,4,0.45); }
.a { box-shadow: 0 1px 0 #080604; }
.b { color: rgba(8,6,4,0.3); }
.c { box-shadow: 0 2px 4px rgba(0,0,0,0.3); }
CSS
out=$(bash "$SCRIPT" "$PROBE/shadows.css" --brand test/fixtures/brand-plotplot-v1.15.0/.brand 2>&1)
n "a Shadow Recipes tint in a shadow custom property passes" 'ERROR \[color\] line 1: ' "$out"
n "a Shadow Recipes tint in a box-shadow passes, as hex too" 'ERROR \[color\] line 2: ' "$out"
t "a Shadow Recipes tint outside a shadow is off the palette" 'ERROR \[color\] line 3: rgba\(8,6,4,0\.3\) \(#080604\) is not in the palette' "$out"
t "a shadow tint the brand does not name is off the palette" 'ERROR \[color\] line 4: rgba\(0,0,0,0\.3\) \(#000000\) is not in the palette' "$out"

# 5. values the check cannot resolve are skipped, as they are today
cat > "$PROBE/unresolved.css" <<'CSS'
.v { color: rgb(var(--r) 0 0); }
.w { color: oklch(calc(0.5 + 0.1) 0.1 30); }
.x { color: oklch(from var(--brand) l c h); }
.y { color: rgb(from #2F6B4F r g b / 50%); }
.z { color: hsl(var(--h), 50%, 50%); background: oklch(0.9640 0.0123 91.52); }
CSS
out=$(bash "$SCRIPT" "$PROBE/unresolved.css" --brand "$BRAND" 2>&1)
n "a colour built from var() is not judged" 'line 1: ' "$out"
n "a colour built from calc() is not judged" 'line 2: ' "$out"
n "relative colour syntax is not judged" 'line [34]: ' "$out"
n "a pair with an unresolved side is not judged" 'line 5: ' "$out"

# 6. quoted output is not a colour; attribute colours are
cat > "$PROBE/page.html" <<'HTML'
<p style="color: oklch(0.6 0.2 30)">styled</p>
<p>Write <code>oklch(0.6 0.2 30)</code> in a token.</p>
<pre>
.a { color: rgb(222 62 45); }
</pre>
<p>rgb(222 62 45) in a sentence is a word.</p>
<svg><rect fill="hsl(5 72% 52%)"/></svg>
HTML
out=$(bash "$SCRIPT" "$PROBE/page.html" --brand "$BRAND" 2>&1)
t "a style attribute in oklch is judged (the issue's known case)" 'ERROR \[color\] line 1: oklch\(0\.6 0\.2 30\)' "$out"
t "the issue's known case fails the check" '^Result: FAIL' "$out"
n "inline <code> is quoted output" 'line 2: ' "$out"
n "a <pre> block is quoted output" 'line 4: ' "$out"
n "text content is not a colour" 'line 6: ' "$out"
t "a fill attribute in hsl() is judged" 'ERROR \[color\] line 7: hsl\(5 72% 52%\)' "$out"
printf 'Write `oklch(0.6 0.2 30)` in a token.\n\n```css\n.a { color: rgb(222 62 45); }\n```\n' > "$PROBE/notes.md"
out=$(bash "$SCRIPT" "$PROBE/notes.md" --brand "$BRAND" 2>&1)
n "markdown code is quoted output" 'ERROR \[color\]' "$out"

# 7. the conversions are the reference ones, on a sweep of inputs
python3 -I - "$GEN" "$PROBE" <<'PY'
import importlib.util, math, random, sys
from fractions import Fraction
gen, probe = sys.argv[1], sys.argv[2]
spec = importlib.util.spec_from_file_location("new_brand", gen)
nb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(nb)
rnd = random.Random(42)
ok = []
# oklch: a grid across the gamut edge, then seeded random four-decimal inputs
for L in [i / 10 for i in range(11)]:
    for C in (0, 0.02, 0.05, 0.08, 0.12, 0.16, 0.2, 0.25, 0.3, 0.37):
        for H in range(0, 360, 15):
            ok.append((L, C, H))
for _ in range(600):
    ok.append((round(rnd.random(), 4), round(rnd.random() * 0.37, 4), round(rnd.random() * 360, 2)))
with open(probe + "/sweep-oklch.css", "w") as f:
    for L, C, H in ok:
        f.write(".k { color: oklch(%s %s %s); }\n" % (L, C, H))
want = []
for L, C, H in ok:
    lin = nb.oklab_to_linear(min(max(L, 0.0), 1.0), C * math.cos(math.radians(H)), C * math.sin(math.radians(H)))
    want.append(nb.oklch_to_hex(L, C, H) if nb.in_gamut(lin) else "outside")
with open(probe + "/sweep-oklch.want", "w") as f:
    f.write("\n".join(want) + "\n")
# hsl: the reference is CSS Color 4's hsl-to-rgb in exact rational arithmetic,
# so a channel that lands on a half rounds up, as the spec's own value does
# (python's colorsys rounds some halves down through float error)
hs = [(h, s, l) for h in range(0, 360, 30) for s in range(0, 101, 20) for l in range(0, 101, 10)]
for _ in range(300):
    hs.append((round(rnd.random() * 360, 2), round(rnd.random() * 100, 2), round(rnd.random() * 100, 2)))
with open(probe + "/sweep-hsl.css", "w") as f:
    for h, s, l in hs:
        f.write(".k { color: hsl(%s %s%% %s%%); }\n" % (h, s, l))
with open(probe + "/sweep-hsl.want", "w") as f:
    for h, s, l in hs:
        h, s, l = Fraction(str(h)) % 360, Fraction(str(s)) / 100, Fraction(str(l)) / 100
        a = s * min(l, 1 - l)
        rgb = [l - a * max(-1, min((n + h / 30) % 12 - 3, 9 - (n + h / 30) % 12, 1)) for n in (0, 8, 4)]
        f.write("#%02X%02X%02X\n" % tuple(math.floor(c * 255 + Fraction(1, 2)) for c in rgb))
PY
judge_sweep() {  # <name>: compares what check.sh says per line with the reference
  bash "$SCRIPT" "$PROBE/sweep-$1.css" --brand "$BRAND" > "$PROBE/sweep-$1.out" 2>&1
  python3 -I - "$BRAND/colors.md" "$PROBE/sweep-$1.want" "$PROBE/sweep-$1.out" <<'PY'
import re, sys
palette = set(h.upper() for h in re.findall(r"#[0-9a-fA-F]{6}", open(sys.argv[1]).read()))
want = open(sys.argv[2]).read().split()
got = {}
for line in open(sys.argv[3]):
    m = re.match(r"ERROR \[color\] line (\d+): \S+\(.*?\) (\(#([0-9A-F]{6})\) is not in the palette|is outside sRGB)", line)
    if m:
        got[int(m.group(1))] = ("#" + m.group(3)) if m.group(3) else "outside"
bad = []
for i, w in enumerate(want, 1):
    expect = None if w in palette else w
    if got.get(i) != expect:
        bad.append("line %d: wanted %s, check.sh said %s" % (i, expect or "a pass", got.get(i, "nothing")))
print("%d %d" % (len(want), len(bad)))
for b in bad[:5]:
    print("# " + b)
PY
}
res=$(judge_sweep oklch)
total=${res%% *}; rest=${res#* }; badn=${rest%%$'\n'*}
if [ "$badn" = 0 ] && [ "${total:-0}" -gt 3000 ]; then echo "ok - the oklch conversion equals new-brand.py's on $total inputs"
else echo "not ok - the oklch conversion equals new-brand.py's on $total inputs ($badn differ)"; printf '%s\n' "$res" | grep '^#'; fails=$((fails+1)); fi
res=$(judge_sweep hsl)
total=${res%% *}; rest=${res#* }; badn=${rest%%$'\n'*}
if [ "$badn" = 0 ] && [ "${total:-0}" -gt 1000 ]; then echo "ok - the hsl conversion equals the exact one on $total inputs"
else echo "not ok - the hsl conversion equals the exact one on $total inputs ($badn differ)"; printf '%s\n' "$res" | grep '^#'; fails=$((fails+1)); fi

echo; echo "$fails failure(s)"; exit "$fails"
