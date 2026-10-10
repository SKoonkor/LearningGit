#!/usr/bin/env bash
# Follow-along repository for Lecture 10.  Run from the course folder:
#   bash codeHints/L10/setup_demo10.sh        (add --reset to rebuild it)
# Builds practice/demo10: main with four commits and the branches side and chain.
# Author and dates are fixed, so the IDs of these starting commits match the lecture.
root="$(cd "$(dirname "$0")/../.." && pwd)"
demo="$root/practice/demo10"

if [ -e "$demo" ] && [ "$1" != "--reset" ]; then
  echo "practice/demo10 already exists. To rebuild it run (from the course folder):"
  echo "  bash codeHints/L10/setup_demo10.sh --reset"
  exit 1
fi
rm -rf "$demo"
mkdir -p "$demo" && cd "$demo" || exit 1
git init -q -b main || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }
git config user.name "Practice User"
git config user.email "practice@example.com"
git config core.autocrlf false
git config commit.gpgsign false

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf '# Recipes\n' > README.md
git add README.md && commit "Add README" "2025-02-01T09:00:00+0000"
printf 'Pancakes: flour, milk, eggs\n' > recipes.txt
git add recipes.txt && commit "Add pancake recipe" "2025-02-02T09:00:00+0000"
printf 'Crepes: flour, milk, eggs, butter\n' >> recipes.txt
git add recipes.txt && commit "Add crepe recipe" "2025-02-03T09:00:00+0000"
printf 'Waffles: flour, milk, eggs, sugar\n' >> recipes.txt
git add recipes.txt && commit "Add waffle recipe" "2025-02-04T09:00:00+0000"

# a side branch (for the merge-undo demo)
git switch -q -c side main~1
printf 'sale banner\n' > banner.txt
git add banner.txt && commit "Add sale banner" "2025-02-05T09:00:00+0000"
git switch -q main

# a branch with a hidden bug (for bisect): a test that passes until step 5
git switch -q --orphan chain
printf '#!/usr/bin/env bash\n# passes while status.txt has no BROKEN line\n! grep -q BROKEN status.txt\n' > test.sh
: > status.txt
git add test.sh status.txt && commit "Start chain" "2025-03-01T09:00:00+0000"
for n in 1 2 3 4 5 6 7 8; do
  if [ "$n" = "5" ]; then printf 'step %s BROKEN\n' "$n" >> status.txt; else printf 'step %s ok\n' "$n" >> status.txt; fi
  git add status.txt && commit "Step $n" "2025-03-0$((n+1))T09:00:00+0000"
done
git switch -q main

echo "Created practice/demo10 (main with 4 commits, branches side and chain)."
echo "Next:  cd practice/demo10   then  git log --oneline --all"
