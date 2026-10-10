#!/usr/bin/env bash
# Setup for Homework 10. Run from the course folder:  bash codeHints/L10/setup_hw10.sh
# Builds practice/hw10 (no server needed):
#   main     3 commits; two more commits were made and then LOST by a hard reset (reflog still has them)
#   messy    three "wip" commits on top of main
#   urgent   a branch from main, for an urgent fix
#   history  a separate chain of 12 commits where a bug appears at some step (for bisect)
# --reset rebuilds it.
root="$(cd "$(dirname "$0")/../.." && pwd)"
hw="$root/practice/hw10"

if [ -e "$hw" ] && [ "$1" != "--reset" ]; then
  echo "practice/hw10 already exists. To start over run (from the course folder):"
  echo "  bash codeHints/L10/setup_hw10.sh --reset"
  exit 1
fi
rm -rf "$hw" "$root/practice/hw10_answers.txt" "$root/practice/.hw10_ids"
mkdir -p "$hw" && cd "$hw" || exit 1
git init -q -b main || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }
git config user.name "Practice User"
git config user.email "practice@example.com"
git config core.autocrlf false
git config commit.gpgsign false
# the fixed commit dates above also date the reflog entries; keep them from expiring
# (and from being cleaned up by an automatic gc) so the recovery exercises always work
git config gc.auto 0
git config gc.reflogExpire never
git config gc.reflogExpireUnreachable never

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf '# Project\n' > README.md
git add README.md && commit "Add README" "2025-04-01T09:00:00+0000"
printf 'run teh app\n' > app.txt
git add app.txt && commit "Add app" "2025-04-02T09:00:00+0000"
printf 'notes\n' > notes.txt
git add notes.txt && commit "Add notes" "2025-04-03T09:00:00+0000"
m3="$(git rev-parse HEAD)"

# the "important work" that gets lost
printf 'draft\n' > work.txt
git add work.txt && commit "Start important work" "2025-04-04T09:00:00+0000"
printf 'draft\nfinal\n' > work.txt
git add work.txt && commit "Important work" "2025-04-05T09:00:00+0000"
l2="$(git rev-parse HEAD)"
git reset -q --hard "$m3"          # oops: both commits are gone from main

git branch urgent "$m3"

git switch -q -c messy "$m3"
printf 'one\n' > feature.txt;            git add feature.txt && commit "wip" "2025-04-06T09:00:00+0000"
w1="$(git rev-parse HEAD)"
printf 'one\ntwo\n' > feature.txt;       git add feature.txt && commit "wip 2" "2025-04-07T09:00:00+0000"
w2="$(git rev-parse HEAD)"
printf 'one\ntwo\nthree\n' > feature.txt; git add feature.txt && commit "more wip" "2025-04-08T09:00:00+0000"
w3="$(git rev-parse HEAD)"
messy_tree="$(git rev-parse 'HEAD^{tree}')"

git switch -q --orphan history
printf '#!/usr/bin/env bash\n# passes while status.txt has no BROKEN line\n! grep -q BROKEN status.txt\n' > test.sh
: > status.txt
git add test.sh status.txt && commit "Start history" "2025-05-01T09:00:00+0000"
first="$(git rev-parse HEAD)"
bad=""
for n in 1 2 3 4 5 6 7 8 9 10 11; do
  if [ "$n" = "7" ]; then printf 'step %s BROKEN\n' "$n" >> status.txt; else printf 'step %s ok\n' "$n" >> status.txt; fi
  git add status.txt && commit "Step $n" "2025-05-$(printf '%02d' $((n+1)))T09:00:00+0000"
  [ "$n" = "7" ] && bad="$(git rev-parse HEAD)"
done
git switch -q main

printf '%s\n' "$m3" "$l2" "$w1" "$w2" "$w3" "$messy_tree" "$first" "$bad" > "$root/practice/.hw10_ids"

echo "Created $hw"
echo "Next:  cd practice/hw10   then  git log --oneline --all   and do tasks 10.1-10.5."
