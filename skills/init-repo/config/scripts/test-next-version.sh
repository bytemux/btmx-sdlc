#!/usr/bin/env bash
# Tests next-version.sh against throwaway git repos. Usage: test-next-version.sh
set -euo pipefail

script="$(cd "$(dirname "$0")" && pwd)/next-version.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fails=0

# new_repo <tag or ""> <commit message>... : repo with one initial commit (tagged
# when a tag is given), then one empty commit per message.
new_repo() {
    local dir tag="$1"
    shift
    dir="$(mktemp -d "$work/repo.XXXX")"
    git -C "$dir" init --quiet
    git -C "$dir" -c user.name=t -c user.email=t@t commit --quiet --allow-empty -m "chore: init"
    [ -z "$tag" ] || git -C "$dir" tag "$tag"
    for msg in "$@"; do
        git -C "$dir" -c user.name=t -c user.email=t@t commit --quiet --allow-empty -m "$msg"
    done
    echo "$dir"
}

# expect <name> <version or ""> <tag or ""> <commit message>...
expect() {
    local name="$1" want="$2" dir out got
    shift 2
    dir="$(new_repo "$@")"
    out="$dir.out"
    : >"$out"
    (cd "$dir" && GITHUB_OUTPUT="$out" GITHUB_STEP_SUMMARY=/dev/null "$script" >/dev/null)
    got="$(sed -n 's/^version=//p' "$out")"
    if [ "$got" = "$want" ]; then
        echo "ok   $name"
    else
        echo "FAIL $name: want '$want', got '$got'"
        fails=$((fails + 1))
    fi
}

expect "first release"           1.0.0 ""     "feat: a"
expect "feat → minor"            1.3.0 v1.2.3 "feat: a"
expect "fix → patch"             1.2.4 v1.2.3 "fix: a"
expect "fix with scope → patch"  1.2.4 v1.2.3 "fix(ui): a (#7)"
expect "perf → patch"            1.2.4 v1.2.3 "perf: a"
expect "feat wins over fix"      1.3.0 v1.2.3 "fix: a" "feat: b" "fix: c"
expect "type! → major"           2.0.0 v1.2.3 "fix: a" "chore!: b"
expect "BREAKING CHANGE footer"  2.0.0 v1.2.3 $'fix: a\n\nBREAKING CHANGE: b'
expect "docs only → none"        ""    v1.2.3 "docs: a" "ci: b" "chore: c"
expect "untyped → none"          ""    v1.2.3 "Create LICENSE"
expect "untyped + fix → patch"   1.2.4 v1.2.3 "Create LICENSE" "fix: a"
expect "nothing since tag"       ""    v1.2.3
expect "uppercase type → none"   ""    v1.2.3 "Feat: a"
expect "merge commit title"      1.3.0 v1.2.3 $'Merge pull request #5 from o/b\n\nfeat: a'

[ "$fails" -eq 0 ] || { echo "$fails failed"; exit 1; }
echo "all passed"
