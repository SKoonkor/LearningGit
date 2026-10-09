#!/usr/bin/env bash
# Setup for Homework 5. Run from the course folder:  bash codeHints/L05/setup_hw5.sh
# Builds practice/hw5: main plus four branches to merge (drinks, desserts, spicy, vegan).
# --reset rebuilds it.
root="$(cd "$(dirname "$0")/../.." && pwd)"
hw="$root/practice/hw5"

if [ -e "$hw" ]; then
  if [ "$1" = "--reset" ] && [ "$(basename "$hw")" = "hw5" ] && [ "$(basename "$(dirname "$hw")")" = "practice" ]; then
    rm -rf "$hw"
  else
    echo "practice/hw5 already exists. To start over run (from the course folder):"
    echo "  bash codeHints/L05/setup_hw5.sh --reset"
    exit 1
  fi
fi

rm -f "$root/practice/hw5_answers.txt"   # never keep stale answers from an earlier attempt
mkdir -p "$hw" && cd "$hw" || exit 1
git init -q -b main || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }
git config --local user.name "Practice User"
git config --local user.email "practice@example.com"
git config --local core.autocrlf false
git config --local commit.gpgsign false

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf '# Menu\n' > README.md
git add README.md && commit "Add README" "2024-08-01T09:00:00+0000"
c1="$(git rev-parse HEAD)"

printf 'Pizza\nPasta\n' > menu.txt
git add menu.txt && commit "Add menu" "2024-08-02T09:00:00+0000"
c2="$(git rev-parse HEAD)"

git switch -q -c drinks
printf 'Water\n' > drinks.txt
git add drinks.txt && commit "Add drinks" "2024-08-03T09:00:00+0000"
d1="$(git rev-parse HEAD)"
git switch -q main

git switch -q -c desserts
printf 'Cake\n' > desserts.txt
git add desserts.txt && commit "Add desserts" "2024-08-04T09:00:00+0000"
e1="$(git rev-parse HEAD)"
git switch -q main

git switch -q -c spicy
printf 'Pizza (spicy)\nPasta\n' > menu.txt
git add menu.txt && commit "Make pizza spicy" "2024-08-05T09:00:00+0000"
s1="$(git rev-parse HEAD)"
git switch -q main

git switch -q -c vegan
printf 'Pizza (vegan)\nPasta\n' > menu.txt
git add menu.txt && commit "Make pizza vegan" "2024-08-06T09:00:00+0000"
v1="$(git rev-parse HEAD)"
git switch -q main

# remember the original commits so the checker can tell if history was rewritten
printf '%s\n%s\n%s\n%s\n%s\n%s\n' "$c1" "$c2" "$d1" "$e1" "$s1" "$v1" > "$root/practice/.hw5_ids"

echo "Created $hw"
echo "Next:  cd practice/hw5   then  git log --oneline --graph --all   and do tasks 5.1-5.6."
