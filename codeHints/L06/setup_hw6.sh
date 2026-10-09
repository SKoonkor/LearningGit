#!/usr/bin/env bash
# Setup for Homework 6. Run from the course folder:  bash codeHints/L06/setup_hw6.sh
# Creates practice/hw6_server.git: a bare repository that plays the role of GitHub
# (a shared "server" copy), with two commits on main. --reset rebuilds it.
root="$(cd "$(dirname "$0")/../.." && pwd)"
server="$root/practice/hw6_server.git"

if [ -e "$server" ]; then
  if [ "$1" = "--reset" ] && [ "$(basename "$server")" = "hw6_server.git" ] && [ "$(basename "$(dirname "$server")")" = "practice" ]; then
    rm -rf "$server" "$root/practice/hw6" "$root/practice/hw6_answers.txt" "$root/practice/.hw6_ids"
  else
    echo "practice/hw6_server.git already exists. To start over run (from the course folder):"
    echo "  bash codeHints/L06/setup_hw6.sh --reset"
    exit 1
  fi
fi

mkdir -p "$root/practice"
git init -q --bare -b main "$server" || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }

# seed the server through a temporary working copy
seed="$(mktemp -d "${TMPDIR:-/tmp}/hw6seed.XXXXXX")"
trap 'rm -rf "$seed"' EXIT
cd "$seed" || exit 1
git init -q -b main
git config user.name "Team Lead"
git config user.email "lead@example.com"
git config core.autocrlf false
git config commit.gpgsign false
git remote add origin "$server"

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}
printf '# Team notes\n' > README.md
git add README.md && commit "Add README" "2024-09-01T09:00:00+0000"
id1="$(git rev-parse HEAD)"
printf 'alpha\n' > notes.txt
git add notes.txt && commit "Add notes" "2024-09-02T09:00:00+0000"
id2="$(git rev-parse HEAD)"
git push -q origin main

printf '%s\n%s\n' "$id1" "$id2" > "$root/practice/.hw6_ids"

echo "Created $server"
echo "This folder plays the role of GitHub. Next, from the practice/ folder:  git clone hw6_server.git hw6"
echo "Then do tasks 6.1-6.7."
