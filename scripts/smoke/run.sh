#!/usr/bin/env bash
# Run conventions-smoke-test.sh against fake gh + local bare remote.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")   # absolute: we cd below
T=$(mktemp -d)
git init -q --bare -b main "$T/remote.git"
git clone -q "$T/remote.git" "$T/seed" 2>/dev/null
# Seed like the real repo after an earlier run: the example files already exist on main.
( cd "$T/seed" && echo "# labapp" > README.md && mkdir -p examples/db \
  && for f in replica-container replica-config replica-performance-test; do
       echo "examples/db/$f.txt (example)" > "examples/db/$f.txt"; done \
  && git add . && git commit -q -m "init" && git push -q origin main )
chmod +x "$ROOT/bin/gh"
export PATH="$ROOT/bin:$PATH" FAKE_GH_STATE="$T/state.json" FAKE_REMOTE="$T/remote.git" \
       FAKE_GH_LOG="$T/gh.log" FAKE_CHECK="$ROOT/check.sh" FAKE_TMP="$T" WORKDIR="$T/clone"
# no sleep in tests
sleep() { :; }; export -f sleep
cd "$T"
bash "$SCRIPT" bytemux/btmx-labapp
echo "---- gh calls: $(wc -l < "$T/gh.log")"
echo "---- state:"; jq -c '.issues[] | {number,title,type,state,fields}' "$T/state.json"; jq -c .subs "$T/state.json"
