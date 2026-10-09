#!/usr/bin/env bash
# Simulates a teammate who pushes to the demo8 server while you work (Lecture 8 demos).
# Run from the course folder, ONLY when the lecture tells you to:
#   bash codeHints/L08/friend8.sh main      # friend pushes a commit to main
#   bash codeHints/L08/friend8.sh sale      # friend pushes a commit to the branch sale
root="$(cd "$(dirname "$0")/../.." && pwd)"
server="$root/practice/demo8_server.git"
branch="$1"
case "$branch" in main|sale) ;; *) echo "usage: bash codeHints/L08/friend8.sh main|sale"; exit 1;; esac
[ -d "$server" ] || { echo "Run setup_demo8.sh first."; exit 1; }
if git --git-dir="$server" log --format=%s "$branch" | grep -qx 'Add friend news'; then
  echo "Your friend has already pushed to $branch. Nothing to do."; exit 0
fi

work="$(mktemp -d "${TMPDIR:-/tmp}/demo8friend.XXXXXX")"
trap 'cd "$root"; rm -rf "$work"' EXIT
git clone -q "$server" "$work/friend" || exit 1
cd "$work/friend" || exit 1
git config user.name "Friend"
git config user.email "friend@example.com"
git config core.autocrlf false
git config commit.gpgsign false
git switch -q "$branch" || exit 1
printf 'friend news\n' > friend.txt
git add friend.txt
git commit -q -m "Add friend news"
git push -q origin "$branch" && echo "Your friend pushed 'Add friend news' to $branch."
