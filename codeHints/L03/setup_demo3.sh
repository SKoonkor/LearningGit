#!/usr/bin/env bash
# Follow-along repository for Lecture 3.  Run from the course folder:
#   bash codeHints/L03/setup_demo3.sh            (add --reset to rebuild it)
# Builds practice/demo3 with four commits. Author and dates are fixed, so the
# commit IDs printed in the lecture are the ones you get (on Windows with
# autocrlf they may differ slightly; the lecture still works).
root="$(cd "$(dirname "$0")/../.." && pwd)"
demo="$root/practice/demo3"

if [ -e "$demo" ]; then
  if [ "$1" = "--reset" ] && [ "$(basename "$demo")" = "demo3" ] && [ "$(basename "$(dirname "$demo")")" = "practice" ]; then
    rm -rf "$demo"
  else
    echo "practice/demo3 already exists. To rebuild it run:"
    echo "  bash codeHints/L03/setup_demo3.sh --reset"
    exit 1
  fi
fi

mkdir -p "$demo" && cd "$demo" || exit 1
git init -q -b main || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }
git config --local user.name "Practice User"
git config --local user.email "practice@example.com"
git config --local core.autocrlf false
git config --local commit.gpgsign false

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf '# Recipes\n' > README.md
git add README.md && commit "Add README" "2024-03-01T09:00:00+0000"

printf 'Pancakes: flour, milk, eggs\n' > recipes.txt
git add recipes.txt && commit "Add pancake recipe" "2024-03-02T09:00:00+0000"

printf 'Crepes: flour, milk, eggs, butter\n' >> recipes.txt
git add recipes.txt && commit "Add crepe recipe" "2024-03-03T09:00:00+0000"

printf 'Waffles: flour, milk, eggs, sugar\n' >> recipes.txt
git add recipes.txt && commit "Add waffle recipe" "2024-03-04T09:00:00+0000"

echo "Created $demo (4 commits). Next:  cd practice/demo3   then  git log --oneline"
