#!/usr/bin/env bash
# Setup for Homework 7 part A. Run from the course folder:  bash codeHints/L07/setup_hw7.sh
# Creates practice/hw7_server.git (plays the role of GitHub) with main (2 commits)
# and a teammate's branch "teammate-feature" (2 commits) waiting for your review.
# --reset rebuilds it.
root="$(cd "$(dirname "$0")/../.." && pwd)"
server="$root/practice/hw7_server.git"

if [ -e "$server" ] && [ "$1" != "--reset" ]; then
  echo "practice/hw7_server.git already exists. To start over run (from the course folder):"
  echo "  bash codeHints/L07/setup_hw7.sh --reset"
  exit 1
fi
# a fresh start always clears leftovers of an earlier attempt
rm -rf "$server" "$root/practice/hw7" "$root/practice/hw7_answers.txt" "$root/practice/.hw7_ids"

mkdir -p "$root/practice"
git init -q --bare -b main "$server" || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }

seed="$(mktemp -d "${TMPDIR:-/tmp}/hw7seed.XXXXXX")"
trap 'cd "$root"; rm -rf "$seed"' EXIT
cd "$seed" || exit 1
git init -q -b main
git config user.name "Maintainer"
git config user.email "maintainer@example.com"
git config core.autocrlf false
git config commit.gpgsign false
git remote add origin "$server"

commit() {  # commit "message" "date" ["author name" "author email"]
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf '# Greeter\n' > README.md
git add README.md && commit "Add README" "2024-10-01T09:00:00+0000"
c1="$(git rev-parse HEAD)"
printf 'print the greeting\n' > app.txt
git add app.txt && commit "Add app" "2024-10-02T09:00:00+0000"
c2="$(git rev-parse HEAD)"
git push -q origin main

git switch -q -c teammate-feature
git config user.name "Teammate"
git config user.email "teammate@example.com"
printf 'Helo, world\n' > greeting.txt
git add greeting.txt && commit "Add greeting" "2024-10-03T09:00:00+0000"
t1="$(git rev-parse HEAD)"
printf 'Run the greeter to see a greeting.\n' >> README.md
git add README.md && commit "Document greeting" "2024-10-04T09:00:00+0000"
t2="$(git rev-parse HEAD)"
git push -q origin teammate-feature

printf '%s\n%s\n%s\n%s\n' "$c1" "$c2" "$t1" "$t2" > "$root/practice/.hw7_ids"

echo "Created $server"
echo "A teammate has pushed the branch 'teammate-feature' and wants it merged into main."
echo "Next, from the practice/ folder:  git clone hw7_server.git hw7   then do tasks 7.1-7.6."
