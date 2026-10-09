#!/usr/bin/env bash
# Follow-along repository for Lecture 4.  Run from the course folder:
#   bash codeHints/L04/setup_demo4.sh        (add --reset to rebuild it)
# Builds practice/demo4 with three commits on main. Author and dates are fixed,
# so the commit IDs printed in the lecture should be the ones you see.
root="$(cd "$(dirname "$0")/../.." && pwd)"
demo="$root/practice/demo4"

if [ -e "$demo" ]; then
  if [ "$1" = "--reset" ] && [ "$(basename "$demo")" = "demo4" ] && [ "$(basename "$(dirname "$demo")")" = "practice" ]; then
    rm -rf "$demo"
  else
    echo "practice/demo4 already exists. To rebuild it run (from the course folder):"
    echo "  bash codeHints/L04/setup_demo4.sh --reset"
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
git add README.md && commit "Add README" "2024-05-01T09:00:00+0000"

printf 'Pancakes: flour, milk, eggs\n' > recipes.txt
git add recipes.txt && commit "Add pancake recipe" "2024-05-02T09:00:00+0000"

printf 'Crepes: flour, milk, eggs, butter\n' >> recipes.txt
git add recipes.txt && commit "Add crepe recipe" "2024-05-03T09:00:00+0000"

echo "Created $demo (3 commits on main). Next:  cd practice/demo4   then  git branch"
