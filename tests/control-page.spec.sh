#!/usr/bin/env bash
# Spec: a hand-built control page with one known violation per rule fails on
# every rule check.sh declares. The rule list comes from the SARIF driver, so
# a rule added without a violation on the control page fails here. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
PAGE=test/fixtures/control/control.html
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
bash "$SCRIPT" "$PAGE" --brand "$BRAND" --product petals --format sarif > "$P/log.sarif"; rc=$?
python3 -I - "$P/log.sarif" "$rc" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8")); rc = int(sys.argv[2])
run = d["runs"][0]
declared = sorted(r["id"] for r in run["tool"]["driver"]["rules"])
fired = {r["ruleId"] for r in run["results"]}
fails = 0
for rid in declared:
    hit = rid in fired
    print(("ok - " if hit else "not ok - ") + "the control page trips " + rid)
    fails += not hit
ok = rc != 0
print(("ok - " if ok else "not ok - ") + "the control page fails the check"); fails += not ok
print(); print("%d failure(s)" % fails); sys.exit(fails)
PY
