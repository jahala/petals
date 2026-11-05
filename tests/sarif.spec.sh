#!/usr/bin/env bash
# Spec: check.sh --format sarif writes a SARIF 2.1.0 log with one result per
# finding the text report prints: same level, same line, a rule id named
# <dimension>/<rule> and declared in the driver, and the nearest-value
# suggestion where the finding has one. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
fails=0
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
compare() { # compare <name> <file> <brand> [args...]
  local name=$1 file=$2 brand=$3; shift 3
  bash "$SCRIPT" "$file" --brand "$brand" "$@" > "$PROBE/text.out" 2>&1; local rc_text=$?
  bash "$SCRIPT" "$file" --brand "$brand" "$@" --format sarif > "$PROBE/log.sarif" 2>"$PROBE/err.out"; local rc_sarif=$?
  out=$(python3 -I - "$PROBE/text.out" "$PROBE/log.sarif" "$file" <<'PY'
import json, re, sys
text, log, target = sys.argv[1], sys.argv[2], sys.argv[3]
found = []
for l in open(text, encoding="utf-8"):
    m = re.match(r'^(ERROR|WARNING) \[([a-z]+)\] (?:line (\d+): )?(.*)$', l.rstrip("\n"))
    if m: found.append((m.group(1).lower().replace("warning", "warning").replace("error", "error"), m.group(2), int(m.group(3)) if m.group(3) else None, m.group(4)))
try: d = json.load(open(log, encoding="utf-8"))
except Exception as e: print("not ok - the log is valid JSON: %s" % e); sys.exit(1)
ok = lambda c, n: print(("ok - " if c else "not ok - ") + n)
ok(d.get("version") == "2.1.0" and "sarif-schema-2.1.0" in d.get("$schema", ""), "version 2.1.0 with the official schema URI")
run = d["runs"][0]; drv = run["tool"]["driver"]
ok(drv.get("name") == "petals" and drv.get("informationUri", "").startswith("https://"), "the driver is petals, with an information URI")
ids = {r["id"] for r in drv.get("rules", [])}
res = run.get("results", [])
ok(len(res) == len(found), "one result per text finding (%d results, %d findings)" % (len(res), len(found)))
good = True
for r, f in zip(res, found):
    level, dim, line, msg = f
    rid = r.get("ruleId", "")
    loc = r["locations"][0]["physicalLocation"]
    if r.get("level") != level or not rid.startswith(dim + "/") or rid not in ids or r["message"]["text"] != msg or not loc["artifactLocation"]["uri"].endswith(target.split("/")[-1]):
        good = False; print("# mismatch: %r vs %r" % (r, f)); break
    if line is not None and loc.get("region", {}).get("startLine") != line: good = False; print("# line mismatch: %r vs %r" % (r, f)); break
    if "Did you mean" in msg and not r.get("properties", {}).get("suggestion"): good = False; print("# missing suggestion: %r" % r); break
ok(good, "each result matches its finding's level, rule, message, file and line")
ok(all(r != "other" and "/" in r and not r.endswith("/other") for r in ids), "every rule id names its rule")
PY
)
  printf '%s\n' "$out" | sed "s/^ok - /ok - $name: /; s/^not ok - /not ok - $name: /"
  fails=$((fails + $(printf '%s\n' "$out" | grep -c '^not ok')))
  [ "$rc_text" = "$rc_sarif" ] && echo "ok - $name: same exit code as the text report" || { echo "not ok - $name: same exit code as the text report ($rc_text vs $rc_sarif)"; fails=$((fails+1)); }
  [ -s "$PROBE/err.out" ] && { echo "not ok - $name: nothing on stderr"; fails=$((fails+1)); } || echo "ok - $name: nothing on stderr"
}
compare bad-css test/fixtures/check/bad.css test/fixtures/brand-plotplot-v2.0.0/.brand --product petals
compare bed-tilth test/fixtures/fonts/bed-tilth.html test/fixtures/brand-plotplot-v1.9.0/.brand
compare garden test/fixtures/garden/reference-product-v1.8.0.html test/fixtures/brand-plotplot-v1.9.0/.brand
echo; echo "$fails failure(s)"; exit "$fails"
