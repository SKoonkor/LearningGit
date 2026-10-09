#!/usr/bin/env bash
# Setup for Homework 4. Run from the course folder:  bash codeHints/L04/setup_hw4.sh
# Builds practice/hw4: two commits on main and one misspelled branch.  --reset rebuilds it.
root="$(cd "$(dirname "$0")/../.." && pwd)"
hw="$root/practice/hw4"

if [ -e "$hw" ]; then
  if [ "$1" = "--reset" ] && [ "$(basename "$hw")" = "hw4" ] && [ "$(basename "$(dirname "$hw")")" = "practice" ]; then
    rm -rf "$hw"
  else
    echo "practice/hw4 already exists. To start over run (from the course folder):"
    echo "  bash codeHints/L04/setup_hw4.sh --reset"
    exit 1
  fi
fi

rm -f "$root/practice/hw4_answers.txt"   # never keep stale answers from an earlier attempt
mkdir -p "$hw" && cd "$hw" || exit 1
git init -q -b main || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }
git config --local user.name "Practice User"
git config --local user.email "practice@example.com"
git config --local core.autocrlf false
git config --local commit.gpgsign false

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf '# My app\n' > README.md
git add README.md && commit "Initial commit" "2024-06-01T09:00:00+0000"
id1="$(git rev-parse HEAD)"

printf 'print hello\n' > app.txt
git add app.txt && commit "Add app file" "2024-06-02T09:00:00+0000"
id2="$(git rev-parse HEAD)"

git branch experimnt "$id1"      # a branch with a typo in its name

printf '%s\n%s\n' "$id1" "$id2" > "$root/practice/.hw4_ids"

echo "Created $hw"
echo "Next:  cd practice/hw4   then  git log --oneline --graph --all   and do tasks 4.1-4.6."
