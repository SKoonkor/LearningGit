#!/usr/bin/env bash
# Follow-along repository for Lecture 8. Run from the course folder:
#   bash codeHints/L08/setup_demo8.sh        (add --reset to rebuild it)
# Creates practice/demo8_server.git (plays the role of GitHub) and a clone practice/demo8.
# The server has main (3 commits) and branches cookies, sale and syrup. Author and dates are
# fixed, so the IDs of these starting commits match the lecture. IDs of commits that YOU create
# (rebases, cherry-picks) depend on the time and will differ.
root="$(cd "$(dirname "$0")/../.." && pwd)"
server="$root/practice/demo8_server.git"
clone="$root/practice/demo8"

if [ -e "$server" ] && [ "$1" != "--reset" ]; then
  echo "practice/demo8_server.git already exists. To rebuild it run (from the course folder):"
  echo "  bash codeHints/L08/setup_demo8.sh --reset"
  exit 1
fi
rm -rf "$server" "$clone"
mkdir -p "$root/practice"
git init -q --bare -b main "$server" || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }

seed="$(mktemp -d "${TMPDIR:-/tmp}/demo8seed.XXXXXX")"
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

printf '# Recipes\n' > README.md
git add README.md && commit "Add README" "2024-11-01T09:00:00+0000"
printf 'Pancakes: flour, milk, eggs\n' > recipes.txt
git add recipes.txt && commit "Add recipes" "2024-11-02T09:00:00+0000"
base="$(git rev-parse HEAD)"

git switch -q -c cookies "$base"
printf 'Cookies: flour, butter, sugar\n' > cookies.txt
git add cookies.txt && commit "Add cookie recipe" "2024-11-03T09:00:00+0000"
printf 'Add chocolate chips\n' >> cookies.txt
git add cookies.txt && commit "wip" "2024-11-04T09:00:00+0000"
printf 'Bake 12 minutes\n' >> cookies.txt
git add cookies.txt && commit "fix typo in cookies" "2024-11-05T09:00:00+0000"
git push -q origin cookies

git switch -q -c sale "$base"
printf 'SALE: 2 for 1 on Tuesdays\n' > banner.txt
git add banner.txt && commit "Add sale banner" "2024-11-06T09:00:00+0000"
git push -q origin sale

git switch -q -c syrup "$base"
printf 'Pancakes: flour, milk, eggs, syrup\n' > recipes.txt
git add recipes.txt && commit "Pancakes with syrup" "2024-11-07T09:00:00+0000"
git push -q origin syrup

git switch -q main
printf 'Muffins: flour, milk\n' >> recipes.txt
git add recipes.txt && commit "Add muffin recipe" "2024-11-08T09:00:00+0000"
git push -q origin main

cd "$root/practice" || exit 1
git clone -q "$server" demo8
cd demo8 || exit 1
git config core.autocrlf false
git config commit.gpgsign false
echo "Created practice/demo8_server.git and the clone practice/demo8."
echo "Next:  cd practice/demo8   then  git branch -r   and   git log --oneline --graph --all"
