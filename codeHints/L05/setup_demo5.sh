#!/usr/bin/env bash
# Follow-along repository for Lecture 5.  Run from the course folder:
#   bash codeHints/L05/setup_demo5.sh        (add --reset to rebuild it)
# Builds practice/demo5: main with two commits and four branches
# (crepes, shopping, syrup, vanilla). Author and dates are fixed, so the
# first commit IDs printed in the lecture should be the ones you see.
root="$(cd "$(dirname "$0")/../.." && pwd)"
demo="$root/practice/demo5"

if [ -e "$demo" ]; then
  if [ "$1" = "--reset" ] && [ "$(basename "$demo")" = "demo5" ] && [ "$(basename "$(dirname "$demo")")" = "practice" ]; then
    rm -rf "$demo"
  else
    echo "practice/demo5 already exists. To rebuild it run (from the course folder):"
    echo "  bash codeHints/L05/setup_demo5.sh --reset"
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
git add README.md && commit "Add README" "2024-07-01T09:00:00+0000"

printf 'Pancakes: flour, milk, eggs\n' > recipes.txt
git add recipes.txt && commit "Add pancake recipe" "2024-07-02T09:00:00+0000"

git switch -q -c crepes
printf 'Crepes: flour, milk, eggs, butter\n' > crepes.txt
git add crepes.txt && commit "Add crepe recipe" "2024-07-03T09:00:00+0000"
git switch -q main

git switch -q -c shopping
printf 'milk\neggs\n' > shopping.txt
git add shopping.txt && commit "Add shopping list" "2024-07-04T09:00:00+0000"
git switch -q main

git switch -q -c syrup
printf 'Pancakes: flour, milk, eggs, syrup\n' > recipes.txt
git add recipes.txt && commit "Pancakes with syrup" "2024-07-05T09:00:00+0000"
git switch -q main

git switch -q -c vanilla
printf 'Pancakes: flour, milk, eggs, vanilla\n' > recipes.txt
git add recipes.txt && commit "Pancakes with vanilla" "2024-07-06T09:00:00+0000"
git switch -q main

echo "Created $demo (main + branches crepes, shopping, syrup, vanilla). Next:  cd practice/demo5   then  git log --oneline --graph --all"
