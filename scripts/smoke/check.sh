# Same script as the run: step of .github/workflows/conventions.yml
t='feat|fix|refactor|perf|test|docs|style|build|ci|chore|revert'
echo "$TITLE"  | grep -Eq "^($t)(\([a-z0-9-]+\))?!?: [a-z0-9].{1,70}$" || { echo "::error::PR title"; exit 1; }
echo "$BRANCH" | grep -Eq "^($t)/[0-9]+-[a-z0-9-]{1,40}$"              || { echo "::error::branch"; exit 1; }
n=$(echo "$BRANCH" | sed -E 's#^[a-z]+/([0-9]+)-.*#\1#')
echo "$BODY" | grep -Eqi "closes #$n\b"                                  || { echo "::error::Closes #$n"; exit 1; }
