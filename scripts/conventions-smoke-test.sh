#!/usr/bin/env bash
# Smoke test of docs/conventions.md on a real repo.
# Flow: Story -> 2 Task sub-issues -> 1 branch + 1 PR per Task -> squash merge -> Story closed.
# Keeps everything: clone dir, local and remote branches, issues, PRs.
# Works with macOS bash 3.2.
# Usage: scripts/conventions-smoke-test.sh [owner/repo]   (default bytemux/btmx-labapp)
set -euo pipefail
REPO=${1:-bytemux/btmx-labapp}
DIR=${WORKDIR:-$PWD/conventions-smoke-$(date +%Y%m%d-%H%M%S)}
API_V="X-GitHub-Api-Version: 2026-03-10"

gh repo clone "$REPO" "$DIR" -- -q
cd "$DIR"
BASE=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
BODIES="$DIR/.smoke-bodies"   # issue bodies, kept for reference
mkdir -p "$BODIES"
echo ".smoke-bodies/" >> .git/info/exclude

# ---------- helpers ----------

set_type() { # set_type <issue> <type>
  gh api -X PATCH "repos/$REPO/issues/$1" -f type="$2" >/dev/null 2>&1 \
    || echo "  ! issue type $2 not set on #$1"
}

set_priority() { # set_priority <issue> <option name>
  if [ -z "$FID" ] || [ -z "$2" ]; then echo "  ! priority not set on #$1 (no Priority field)"; return; fi
  printf '{"issue_field_values":[{"field_id":%s,"value":"%s"}]}' "$FID" "$2" \
    | gh api -H "$API_V" -X POST "repos/$REPO/issues/$1/issue-field-values" --input - >/dev/null \
    || echo "  ! priority $2 not set on #$1"
}

new_issue() { # new_issue <title> <type> <priority option> <body file>  -> sets NEW
  local url
  url=$(gh issue create --title "$1" --body-file "$4")
  NEW=${url##*/}
  set_type "$NEW" "$2"
  set_priority "$NEW" "$3"
  echo "  #$NEW $1 ($2, priority: ${3:-none})"
}

link_sub() { # link_sub <story> <task>
  local id
  id=$(gh api "repos/$REPO/issues/$2" -q .id)
  gh api -X POST "repos/$REPO/issues/$1/sub_issues" -F sub_issue_id="$id" >/dev/null
  echo "  #$2 -> sub-issue of #$1"
}

commit_file() { # commit_file <path> <message> <issue>
  mkdir -p "$(dirname "$1")"
  # Content names the issue: earlier runs left the same files on the base branch,
  # and an unchanged file gives "nothing to commit".
  echo "$1 (example for #$3)" > "$1"
  git add "$1"
  git commit -q -m "$2" -m "Refs #$3"
  echo "  commit: $2"
}

wait_and_merge() { # wait_and_merge <pr url>  (no CI check: gates run locally)
  gh pr merge "$1" --squash
}

state() { gh issue view "$1" --json state -q .state; }

# ---------- setup ----------

echo "== priority field"
SEL='.[] | select(.name=="Priority")'
FID=$(gh api -H "$API_V" user/issue-fields -q "$SEL | .id" || true)
P2=""; P3=""
if [ -n "$FID" ]; then
  echo "  field id $FID, options (highest first):"
  gh api -H "$API_V" user/issue-fields -q "$SEL | .options | sort_by(.priority) | .[] | \"    \" + .name"
  P2=$(gh api -H "$API_V" user/issue-fields -q "$SEL | .options | sort_by(.priority) | .[1].name")
  P3=$(gh api -H "$API_V" user/issue-fields -q "$SEL | .options | sort_by(.priority) | .[2].name")
else
  echo "  ! no Priority field found"
fi

echo "== merge settings (branches kept after merge for this test)"
gh repo edit --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge=false
gh api -X PATCH "repos/$REPO" -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY >/dev/null

# ---------- issues ----------

cat > "$BODIES/story.md" <<'EOF'
## Type
Story

## Goal
As a user I keep my data when the main db fails.

## Acceptance criteria
- replica db runs next to the main db
- replica keeps up under expected load

## Out of scope
Automatic failover.
EOF

echo "== story"
new_issue "Replicate db" Story "$P2" "$BODIES/story.md"
STORY=$NEW

cat > "$BODIES/task1.md" <<EOF
## Goal
Run a replica db next to the main db.

## Acceptance criteria
- replica container starts
- replica config is in the repo
EOF

cat > "$BODIES/task2.md" <<EOF
## Goal
Check that the replica keeps up.

## Acceptance criteria
- performance test exists and runs
EOF

echo "== tasks"
new_issue "Set up db" Task "$P2" "$BODIES/task1.md"
T1=$NEW
new_issue "Test performance" Task "$P3" "$BODIES/task2.md"
T2=$NEW
link_sub "$STORY" "$T1"
link_sub "$STORY" "$T2"

# ---------- task 1 ----------

echo "== task 1: #$T1"
B1="feat/$T1-set-up-db"
gh issue develop "$T1" --name "$B1" --base "$BASE" --checkout
commit_file examples/db/replica-container.txt "feat: add db replica container" "$T1"
commit_file examples/db/replica-config.txt "feat(db): add replica config" "$T1"
git push -q -u origin "$B1"
PR1=$(gh pr create --base "$BASE" --head "$B1" --title "feat: set up db" --body "Closes #$T1")
echo "  PR: $PR1"
wait_and_merge "$PR1"

# ---------- task 2 ----------

echo "== task 2: #$T2"
git checkout -q "$BASE"
git pull -q
B2="test/$T2-test-performance"
gh issue develop "$T2" --name "$B2" --base "$BASE" --checkout
commit_file examples/db/replica-performance-test.txt "test: add db replica performance test" "$T2"
git push -q -u origin "$B2"
PR2=$(gh pr create --base "$BASE" --head "$B2" --title "test: add db performance test" --body "Closes #$T2")
echo "  PR: $PR2"
wait_and_merge "$PR2"

# ---------- story ----------

echo "== close story"
gh issue close "$STORY" --reason completed --comment "All Tasks closed: #$T1, #$T2" >/dev/null
git checkout -q "$BASE"
git pull -q

# ---------- report ----------

echo
echo "Clone:   $DIR"
echo "Story:   https://github.com/$REPO/issues/$STORY  ($(state "$STORY"))"
echo "Task 1:  https://github.com/$REPO/issues/$T1  ($(state "$T1"))"
echo "Task 2:  https://github.com/$REPO/issues/$T2  ($(state "$T2"))"
echo "Sub-issues of #$STORY:"
gh api "repos/$REPO/issues/$STORY/sub_issues" -q '.[] | "  #\(.number) \(.title) (\(.state))"'
echo "PR 1:    $PR1"
echo "PR 2:    $PR2"
echo "Branch $B1:"
git --no-pager log --format='  %s' "origin/$BASE~2..origin/$B1"
echo "Branch $B2:"
git --no-pager log --format='  %s' "origin/$BASE~1..origin/$B2"
echo "Last 2 commits on $BASE:"
git --no-pager log -2 --format='  %s%n  %b' "origin/$BASE"
