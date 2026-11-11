#!/usr/bin/env bash
# Spec: `new-brand.py system` turns one direction request into a full design
# system, and the arithmetic holds the owner's rules. The known requests are
# in test/fixtures/directions/, each beside the system it must print.
#   - every documented pair meets its class's floor in both themes: reading
#     4.5:1 and labels 3:1, or reading 7:1 and labels 4.5:1 at high contrast;
#   - an exact seed comes back unchanged, and a seed too light for words gets
#     a primary-text shade and an on-primary colour, named in the receipt;
#   - a bounded seed moves no further than its stated CIEDE2000 distance;
#   - roles a person must tell apart stay DISTANCE apart in both themes;
#   - the same request prints the same bytes;
#   - a bad request exits 2 with one line naming the field;
#   - the contrast answers are check.sh's own: check.sh passes every
#     documented pair, flags a weakened one, and prints the same ratios.
# Prints TAP. Run from the repo root: bash tests/directions.spec.sh
cd "$(dirname "$0")/.." || exit 1
GEN=petals/scripts/new-brand.py
CHECK=petals/scripts/check.sh
FX=test/fixtures/directions
# The role distance is a dial (see the docstring of new-brand.py). The spec
# holds the script to this value, so a change to the dial changes both.
DISTANCE=12
fails=0
ok() { echo "ok - $1"; }
no() { echo "not ok - $1"; fails=$((fails+1)); }
t() { if echo "$3" | grep -qE -e "$2"; then ok "$1"; else no "$1: wanted /$2/"; fi }
n() { if echo "$3" | grep -qE -e "$2"; then no "$1: did not want /$2/"; else ok "$1"; fi }

P=$(mktemp -d); trap 'rm -rf "$P"' EXIT

# 1. each known request prints its stored system, the same bytes every run
for req in "$FX"/*.request.json; do
  base=$(basename "$req" .request.json)
  python3 -I "$GEN" system "$req" > "$P/$base.1.json" 2> "$P/$base.err"; code=$?
  if [ "$code" -eq 0 ] && [ ! -s "$P/$base.err" ]; then ok "$base: system exits 0 with nothing on stderr"
  else no "$base: system exits 0 with nothing on stderr (exit $code: $(head -1 "$P/$base.err"))"; fi
  python3 -I "$GEN" system "$req" > "$P/$base.2.json" 2>/dev/null
  if [ -s "$P/$base.1.json" ] && cmp -s "$P/$base.1.json" "$P/$base.2.json"; then ok "$base: two runs print the same bytes"
  else no "$base: two runs print the same bytes"; fi
  if [ -f "$FX/$base.system.json" ] && cmp -s "$P/$base.1.json" "$FX/$base.system.json"; then ok "$base: the output is the stored $base.system.json"
  else no "$base: the output is the stored $base.system.json"; fi
done

# 2. the rules, judged on what the script prints now for each known request
python3 -I - "$GEN" "$FX" "$DISTANCE" "$P" <<'PY'
import glob, importlib.util, json, os, re, sys
gen_path, fx, distance, out = sys.argv[1], sys.argv[2], float(sys.argv[3]), sys.argv[4]
fails = 0

def ok(cond, msg, detail=()):
    global fails
    print(("ok - " if cond else "not ok - ") + msg)
    if not cond:
        for d in detail:
            print("# " + d)
        fails += 1

try:
    spec = importlib.util.spec_from_file_location("new_brand", gen_path)
    nb = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(nb)
except Exception as exc:  # the script is missing or broken: every rule below fails
    ok(False, "new-brand.py loads as a module (%s)" % exc)
    sys.exit(1)

# The instrument, checked on known cases first: Sharma, Wu and Dalal's
# CIEDE2000 test data (2005), and issue #14's measured pair.
SHARMA = [
    ((50.0, 2.6772, -79.7751), (50.0, 0.0, -82.7485), 2.0425),
    ((50.0, 3.1571, -77.2803), (50.0, 0.0, -82.7485), 2.8615),
    ((50.0, 0.0, 0.0), (50.0, -1.0, 2.0), 2.3669),
    ((50.0, 2.49, -0.001), (50.0, -2.49, 0.0009), 7.1792),
    ((50.0, 2.49, -0.001), (50.0, -2.49, 0.0011), 7.2195),
    ((50.0, -0.001, 2.49), (50.0, 0.0011, -2.49), 4.7461),
    ((50.0, 2.5, 0.0), (73.0, 25.0, -18.0), 27.1492),
    ((50.0, 2.5, 0.0), (61.0, -5.0, 29.0), 22.8977),
    ((50.0, 2.5, 0.0), (56.0, -27.0, -3.0), 31.903),
    ((60.2574, -34.0099, 36.2677), (60.4626, -34.1751, 39.4387), 1.2644),
    ((22.7233, 20.0904, -46.694), (23.0331, 14.973, -42.5619), 2.0373),
]
bad = ["%s %s: %.4f, wanted %.4f" % (a, b, nb.ciede2000(a, b), want) for a, b, want in SHARMA
       if abs(nb.ciede2000(a, b) - want) > 0.00005]
ok(not bad, "CIEDE2000 matches the published test data to four decimals", bad)
d = nb.delta_e("#C0B47A", "#C7C784")
ok(abs(d - 5.9) < 0.05, "CIEDE2000 measures issue #14's pair at 5.9 (got %.2f)" % d)

ROLES = ["primary", "on-primary", "accent", "text", "text-soft", "bg", "surface", "border",
         "error", "success", "warning", "info"]
STATUS = ["error", "success", "warning", "info"]
FLOORS = {"standard": {"reading": 4.5, "labels": 3.0}, "high": {"reading": 7.0, "labels": 4.5}}
HEX = re.compile(r"#[0-9A-F]{6}$")

def fresh(base):
    """What the script printed for this request in step 1, or None."""
    try:
        return json.load(open(os.path.join(out, base + ".1.json")))
    except ValueError:
        return None

for rpath in sorted(glob.glob(os.path.join(fx, "*.request.json"))):
    base = os.path.basename(rpath)[: -len(".request.json")]
    req = json.load(open(rpath))
    path = os.path.join(out, base + ".1.json")
    sysm = fresh(base)
    if sysm is None:
        ok(False, "%s: the script printed a system to judge" % base)
        continue
    floors = FLOORS[req["contrast"]]
    themes = ("light", "dark")

    ok(sysm.get("name") == req["name"] and sysm.get("prefix") == "--%s-" % req["name"],
       "%s: name and prefix come from the request" % base)
    missing = ["%s.%s" % (t, r) for t in themes for r in ROLES if r not in sysm.get(t, {})]
    ok(not missing, "%s: both palettes carry every role" % base, missing)
    ok(set(sysm["light"]) == set(sysm["dark"]), "%s: the two palettes carry the same roles" % base)
    badhex = ["%s.%s=%s" % (t, r, v) for t in themes for r, v in sysm[t].items() if not HEX.match(v)]
    ok(not badhex, "%s: every colour is a six-digit uppercase hex" % base, badhex)

    # every documented pair meets its floor, in each theme
    pairs = sysm.get("pairs", [])
    low, wrong = [], []
    for p in pairs:
        fg, bg = sysm[p["theme"]][p["fg"]], sysm[p["theme"]][p["bg"]]
        r = nb.ratio(fg, bg)
        if "%.2f" % r != "%.2f" % p["ratio"]:
            wrong.append("%s %s on %s: stated %.2f, measured %.2f" % (p["theme"], p["fg"], p["bg"], p["ratio"], r))
        if p["class"] != "decorative" and r < floors[p["class"]]:
            low.append("%s %s %s on %s %s: %.3f < %s (%s)" % (p["theme"], p["fg"], fg, p["bg"], bg, r, floors[p["class"]], p["class"]))
    ok(pairs and not low, "%s: every documented pair meets its class's floor (%s contrast)" % (base, req["contrast"]), low)
    ok(not wrong, "%s: every stated ratio is the measured one" % base, wrong)
    ok(all(p["class"] in ("reading", "labels", "decorative") for p in pairs),
       "%s: every pair carries a class check.sh's Contrast Pairings table reads" % base)

    def has(theme, fg, bg, classes):
        return any(p["theme"] == theme and p["fg"] == fg and p["bg"] == bg and p["class"] in classes for p in pairs)
    need = [(t, fg, bg, cls) for t in themes for fg, bg, cls in
            [("text", "bg", ("reading",)), ("text", "surface", ("reading",)),
             ("text-soft", "bg", ("reading",)), ("text-soft", "surface", ("reading",)),
             ("on-primary", "primary", ("reading", "labels"))]
            + [(s, "bg", ("reading", "labels")) for s in STATUS]]
    gaps = ["%s %s on %s as %s" % (t, fg, bg, "/".join(c)) for t, fg, bg, c in need if not has(t, fg, bg, c)]
    ok(not gaps, "%s: text, soft text, on-primary and every status colour are documented pairs in both themes" % base, gaps)
    if "primary-text" in sysm["light"]:
        gaps = [t for t in themes if not has(t, "primary-text", "bg", ("reading",))]
        ok(not gaps, "%s: primary-text is a reading pair on bg in both themes" % base, gaps)

    # roles a person must tell apart stay apart
    ok(sysm.get("distance") == distance, "%s: the system states the role distance, %s" % (base, distance))
    apart = [("primary", "accent")] + [(a, b) for i, a in enumerate(STATUS) for b in STATUS[i + 1:]] \
        + [(s, "primary") for s in STATUS]
    if "primary-text" in sysm["light"]:
        apart += [("primary-text", "accent")] + [(s, "primary-text") for s in STATUS]
    close = []
    for t in themes:
        for a, b in apart:
            de = nb.delta_e(sysm[t][a], sysm[t][b])
            if de < distance:
                close.append("%s %s %s and %s %s: %.2f" % (t, a, sysm[t][a], b, sysm[t][b], de))
    ok(not close, "%s: primary and accent, the four status colours, and each status and the primary are at least %s apart in both themes" % (base, distance), close)

    # the seed and its hold
    key = req["key"]
    receipt = sysm.get("receipt", [])
    text = json.dumps(receipt)
    if "hex" in key:
        seed = key["hex"].upper()
        ok(seed in text and key["hold"] in text, "%s: the receipt records the seed and its hold" % base)
        if key["hold"] == "exact":
            ok(sysm["light"]["primary"] == seed and sysm["dark"]["primary"] == seed,
               "%s: the exact seed %s is the primary in both themes, unchanged" % (base, seed))
        if key["hold"] == "bounded":
            far = ["%s %s: %.2f" % (t, sysm[t]["primary"], nb.delta_e(sysm[t]["primary"], seed)) for t in themes
                   if nb.delta_e(sysm[t]["primary"], seed) > key["within"]]
            ok(not far, "%s: the bounded seed moves no further than %s in either theme" % (base, key["within"]), far)
            ok(any(sysm[t]["primary"] != seed for t in themes),
               "%s: the bounded seed did move, so the bound was exercised" % base)
    if key.get("hold") == "exact" and nb.ratio(key["hex"], sysm["light"]["bg"]) < floors["reading"]:
        ok("primary-text" in sysm["light"], "%s: a seed too light for words gets a primary-text shade" % base)
        named = [e for e in receipt if e.get("role") == "primary-text"]
        ok(named and all(e.get("why") for e in named), "%s: the receipt names the primary-text shade and why" % base)
        named = [e for e in receipt if e.get("role") == "on-primary"]
        ok(named and all(e.get("why") for e in named), "%s: the receipt names the on-primary colour and why" % base)
    moved = [e for e in receipt if e.get("from") and e.get("to") and e["from"] != e["to"]]
    ok(all(e.get("why") for e in moved), "%s: every moved value in the receipt says why" % base)

    # the scales
    space = sysm.get("space", {}).get("scale", {})
    off = [v for v in space.values() if not re.fullmatch(r"\d+px", v) or int(v[:-2]) % 4]
    ok(space and not off, "%s: every spacing step is a multiple of 4px, check.sh's spacing unit" % base, off)
    rad = sysm.get("radius", {})
    ok(rad and all(re.fullmatch(r"\d+px", v) for v in rad.values()) and "radius-full" in rad,
       "%s: the radius scale is whole pixels with a full radius" % base)
    sizes = [int(l["size"][:-2]) for l in sysm.get("type", {}).get("levels", [])]
    ok(len(sizes) == 6 and sizes == sorted(sizes, reverse=True) and len(set(sizes)) == 6,
       "%s: the type scale has six distinct sizes, largest first" % base, [str(sizes)])
    eases = [v for v in sysm.get("motion", {}).values() if "cubic-bezier" in v]
    params = [float(x) for v in eases for x in v[v.index("(") + 1:-1].split(",")]
    ok(eases and all(0 <= x <= 1 for x in params), "%s: the easing has no overshoot" % base)
    ok("\u2014" not in open(path, encoding="utf-8").read(), "%s: the output carries no em dash" % base)

sys.exit(fails)
PY
fails=$((fails+$?))

# 3. a bad request exits 2 with one line naming the field
GOOD='"loudness": "quiet", "neutrals": "warm", "contrast": "standard", "shape": "soft", "density": "roomy"'
bad() {
  printf '%s\n' "$2" > "$P/bad.json"
  python3 -I "$GEN" system "$P/bad.json" > "$P/bad.out" 2> "$P/bad.err"; code=$?
  lines=$(wc -l < "$P/bad.err" | tr -d ' '); named=0
  case "$(cat "$P/bad.err")" in "new-brand: $1: "*) named=1 ;; esac
  if [ "$code" -eq 2 ] && [ "$lines" -eq 1 ] && [ ! -s "$P/bad.out" ] && [ "$named" -eq 1 ]; then ok "a request with $3 exits 2 naming $1"
  else no "a request with $3 exits 2 naming $1 (exit $code, $lines line(s): $(head -1 "$P/bad.err"))"; fi
}
bad name "{\"name\": \"Quince\", \"key\": {\"hue\": 40}, $GOOD}" "an uppercase name"
bad loudness "{\"name\": \"q\", \"key\": {\"hue\": 40}, \"loudness\": \"medium\", \"neutrals\": \"warm\", \"contrast\": \"standard\", \"shape\": \"soft\", \"density\": \"roomy\"}" "an unknown loudness"
bad density "{\"name\": \"q\", \"key\": {\"hue\": 40}, \"loudness\": \"quiet\", \"neutrals\": \"warm\", \"contrast\": \"standard\", \"shape\": \"soft\"}" "no density"
bad key.within "{\"name\": \"q\", \"key\": {\"hex\": \"#336699\", \"hold\": \"bounded\"}, $GOOD}" "a bounded hold and no distance"
bad key.within "{\"name\": \"q\", \"key\": {\"hex\": \"#336699\", \"hold\": \"exact\", \"within\": 4}, $GOOD}" "a distance on an exact hold"
bad key.hold "{\"name\": \"q\", \"key\": {\"hex\": \"#336699\", \"hold\": \"loose\"}, $GOOD}" "an unknown hold"
bad key.hex "{\"name\": \"q\", \"key\": {\"hex\": \"#369\", \"hold\": \"exact\"}, $GOOD}" "a three-digit hex"
bad key.hue "{\"name\": \"q\", \"key\": {\"hue\": 400}, $GOOD}" "a hue past 360"
bad key "{\"name\": \"q\", \"key\": {\"hue\": 40, \"hex\": \"#336699\", \"hold\": \"exact\"}, $GOOD}" "both a hue and a hex"
bad fonts "{\"name\": \"q\", \"key\": {\"hue\": 40}, \"fonts\": \"serif\", $GOOD}" "a field the request does not have"
bad request "{\"name\": \"q\"," "broken JSON"

# 4. check.sh agrees: a brand whose Contrast Pairings table lists the
#    generated pairs, and a page that sets each pair as text
python3 -I - "$GEN" "$FX" "$P" <<'PY'
import glob, importlib.util, json, os, random, sys
gen_path, fx, out = sys.argv[1:4]
spec = importlib.util.spec_from_file_location("new_brand", gen_path)
nb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(nb)

def brand(folder, rows):
    os.makedirs(folder, exist_ok=True)
    with open(os.path.join(folder, "colors.md"), "w") as f:
        f.write("# Brand Colors: probe\n\n## Contrast Pairings\n\n| Foreground on background | Ratio | Class |\n|---|---|---|\n")
        for fg, bg, cls in rows:
            f.write("| Fg %s on Bg %s | %.2f | %s |\n" % (fg, bg, nb.ratio(fg, bg), cls))

def page(path, rows):
    with open(path, "w") as f:
        for i, (fg, bg, _) in enumerate(rows, 1):
            f.write(".p%d { color: %s; background: %s; }\n" % (i, fg, bg))

every = []
for rpath in sorted(glob.glob(os.path.join(fx, "*.request.json"))):
    base = os.path.basename(rpath)[: -len(".request.json")]
    try:
        s = json.load(open(os.path.join(out, base + ".1.json")))
    except ValueError:
        continue
    rows = [(s[p["theme"]][p["fg"]], s[p["theme"]][p["bg"]], p["class"]) for p in s["pairs"]]
    every += rows
    words = [r for r in rows if r[2] != "decorative"]
    brand(os.path.join(out, base, "brand"), rows)
    page(os.path.join(out, base, "words.css"), words)
    deco = [r for r in rows if r[2] == "decorative"]
    page(os.path.join(out, base, "decorative.css"), deco)
    # a weakened pair: a grey just under the reading floor on the first
    # reading pair's background, and one just over it
    bg = next(r[1] for r in rows if r[2] == "reading")
    greys = ["#%02X%02X%02X" % (v, v, v) for v in range(256)]
    under = max((g for g in greys if nb.ratio(g, bg) < 4.5), key=lambda g: nb.ratio(g, bg))
    over = min((g for g in greys if nb.ratio(g, bg) >= 4.5), key=lambda g: nb.ratio(g, bg))
    brand(os.path.join(out, base, "weak"), rows + [(under, bg, "reading"), (over, bg, "reading")])
    page(os.path.join(out, base, "under.css"), [(under, bg, "reading")])
    page(os.path.join(out, base, "over.css"), [(over, bg, "reading")])
    print(base, file=open(os.path.join(out, "bases.txt"), "a"))

# the same ratios: every generated pair and 300 random ones, all decorative,
# so check.sh prints each ratio it measures
rnd = random.Random(5)
for _ in range(300):
    every.append(("#%06X" % rnd.randrange(1 << 24), "#%06X" % rnd.randrange(1 << 24), "decorative"))
rows = [(fg, bg, "decorative") for fg, bg, _ in every]
brand(os.path.join(out, "ratios", "brand"), rows)
page(os.path.join(out, "ratios", "page.css"), rows)
with open(os.path.join(out, "ratios", "want.txt"), "w") as f:
    for fg, bg, _ in rows:
        f.write("%s %s %.2f\n" % (fg, bg, nb.ratio(fg, bg)))
PY
[ -f "$P/bases.txt" ] || no "the agreement pages were written"
while read -r base; do
  D="$P/$base"
  out=$(bash "$CHECK" "$D/words.css" --brand "$D/brand" 2>&1)
  n "$base: check.sh finds no contrast fault in any documented pair set as words" '\[color\]' "$out"
  if [ -s "$D/decorative.css" ]; then
    out=$(bash "$CHECK" "$D/decorative.css" --brand "$D/brand" 2>&1)
    want=$(wc -l < "$D/decorative.css" | tr -d ' '); got=$(printf '%s\n' "$out" | grep -c 'decorative-only pair')
    if [ "$want" -eq "$got" ]; then ok "$base: check.sh flags each decorative pair set as words ($got)"
    else no "$base: check.sh flags each decorative pair set as words ($got of $want)"; fi
  fi
  out=$(bash "$CHECK" "$D/under.css" --brand "$D/weak" 2>&1)
  t "$base: check.sh flags a reading pair weakened just under 4.5:1" 'ERROR \[color\] line 1: .*below the 4.5:1 reading minimum' "$out"
  out=$(bash "$CHECK" "$D/over.css" --brand "$D/weak" 2>&1)
  n "$base: check.sh passes the pair just over 4.5:1" '\[color\]' "$out"
done < "$P/bases.txt"
if [ -f "$P/ratios/page.css" ]; then
  bash "$CHECK" "$P/ratios/page.css" --brand "$P/ratios/brand" 2>&1 \
    | sed -nE 's/^ERROR \[color\] line [0-9]+: (#[0-9A-F]{6}) on (#[0-9A-F]{6}) is ([0-9.]+):1.*/\1 \2 \3/p' > "$P/ratios/got.txt"
  if [ -s "$P/ratios/got.txt" ] && cmp -s "$P/ratios/want.txt" "$P/ratios/got.txt"; then
    ok "the generator's contrast ratio equals check.sh's on $(wc -l < "$P/ratios/want.txt" | tr -d ' ') pairs"
  else
    no "the generator's contrast ratio equals check.sh's"
    diff "$P/ratios/want.txt" "$P/ratios/got.txt" | head -5 | sed 's/^/# /'
  fi
fi

echo; echo "$fails failure(s)"; exit "$fails"
