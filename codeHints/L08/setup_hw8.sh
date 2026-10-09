#!/usr/bin/env bash
# Setup for Homework 8. Run from the course folder:  bash codeHints/L08/setup_hw8.sh
# Creates practice/hw8_server.git (plays the role of GitHub) with:
#   main     (3 commits, the newest changes README.md)
#   feature  (5 messy commits that began before main's newest commit)
#   hotfix   (1 commit that fixes app.txt)
# --reset rebuilds it.
root="$(cd "$(dirname "$0")/../.." && pwd)"
server="$root/practice/hw8_server.git"

if [ -e "$server" ] && [ "$1" != "--reset" ]; then
  echo "practice/hw8_server.git already exists. To start over run (from the course folder):"
  echo "  bash codeHints/L08/setup_hw8.sh --reset"
  exit 1
fi
rm -rf "$server" "$root/practice/hw8" "$root/practice/hw8_answers.txt" "$root/practice/.hw8_ids"
mkdir -p "$root/practice"
git init -q --bare -b main "$server" || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }

seed="$(mktemp -d "${TMPDIR:-/tmp}/hw8seed.XXXXXX")"
trap 'cd "$root"; rm -rf "$seed"' EXIT
cd "$seed" || exit 1
git init -q -b main
git config user.name "Practice User"
git config user.email "practice@example.com"
git config core.autocrlf false
git config commit.gpgsign false
git remote add origin "$server"

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf '# Greeter\n' > README.md
git add README.md && commit "Add README" "2024-12-01T09:00:00+0000"
r1="$(git rev-parse HEAD)"
printf 'print the greeting\n' > app.txt
git add app.txt && commit "Add app" "2024-12-02T09:00:00+0000"
r2="$(git rev-parse HEAD)"

git switch -q -c feature "$r2"
printf 'Hello, world\n' > greeting.txt
printf 'Usage: run the greeter.\n' >> README.md
git add greeting.txt README.md && commit "Add greeting" "2024-12-03T09:00:00+0000"
f1="$(git rev-parse HEAD)"
printf 'Welcome!!\n' >> greeting.txt
git add greeting.txt && commit "wip" "2024-12-04T09:00:00+0000"
f2="$(git rev-parse HEAD)"
printf 'Hello, world\nWelcome!\n' > greeting.txt
git add greeting.txt && commit "fix typo" "2024-12-05T09:00:00+0000"
f3="$(git rev-parse HEAD)"
printf 'Goodbye\n' > farewell.txt
git add farewell.txt && commit "add farewell" "2024-12-06T09:00:00+0000"
f4="$(git rev-parse HEAD)"
printf 'See you soon\n' >> farewell.txt
git add farewell.txt && commit "oops" "2024-12-07T09:00:00+0000"
f5="$(git rev-parse HEAD)"
git push -q origin feature

git switch -q -c hotfix "$r2"
printf 'print the greeting safely\n' > app.txt
git add app.txt && commit "Fix crash in app" "2024-12-08T09:00:00+0000"
h1="$(git rev-parse HEAD)"
git push -q origin hotfix

git switch -q main
printf 'Maintained by the team.\n' >> README.md
git add README.md && commit "Update README" "2024-12-09T09:00:00+0000"
r3="$(git rev-parse HEAD)"
git push -q origin main

printf '%s\n' "$r1" "$r2" "$r3" "$f1" "$f2" "$f3" "$f4" "$f5" "$h1" > "$root/practice/.hw8_ids"

echo "Created $server"
echo "Next, from the practice/ folder:  git clone hw8_server.git hw8   then do tasks 8.1-8.6."
