#!/usr/bin/env bash
# Setup for Homework 3. Run from the course folder:  bash codeHints/L03/setup_hw3.sh
# Builds practice/hw3: four commits plus a messy working state.  --reset rebuilds it.
root="$(cd "$(dirname "$0")/../.." && pwd)"
hw="$root/practice/hw3"

if [ -e "$hw" ]; then
  if [ "$1" = "--reset" ] && [ "$(basename "$hw")" = "hw3" ] && [ "$(basename "$(dirname "$hw")")" = "practice" ]; then
    rm -rf "$hw" "$root/practice/.hw3_ids" "$root/practice/hw3_answers.txt"
  else
    echo "practice/hw3 already exists. To start over run:"
    echo "  bash codeHints/L03/setup_hw3.sh --reset"
    exit 1
  fi
fi

mkdir -p "$hw" && cd "$hw" || exit 1
git init -q -b main || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }
git config --local user.name "Practice User"
git config --local user.email "practice@example.com"
git config --local core.autocrlf false

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf 'milk\neggs\n' > list.txt
git add list.txt && commit "Add shopping list" "2024-04-01T09:00:00+0000"
id1="$(git rev-parse HEAD)"

printf 'Pancakes need flour\n' > notes.txt
git add notes.txt && commit "Add recipe notes" "2024-04-02T09:00:00+0000"
id2="$(git rev-parse HEAD)"

printf 'fireworks\n' >> list.txt
git add list.txt && commit "Buy fireworks" "2024-04-03T09:00:00+0000"
id3="$(git rev-parse HEAD)"

printf 'Whisk well\n' >> notes.txt
git add notes.txt && commit "Update notse" "2024-04-04T09:00:00+0000"

# the messy working state
printf 'oops delete me\n' >> list.txt          # junk, not staged
printf 'TODO: add syrup\n' >> notes.txt        # real work, but staged too early
git add notes.txt

# remember the first three IDs so the checker can tell if history was rewritten
printf '%s\n%s\n%s\n' "$id1" "$id2" "$id3" > "$root/practice/.hw3_ids"

echo "Created $hw"
echo "Next:  cd practice/hw3   then  git status   and do tasks 3.1-3.6."
