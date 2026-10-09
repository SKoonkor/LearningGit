#!/usr/bin/env bash
# Simulates a teammate who pushes a commit to the shared server while you work.
# Run from the course folder, ONLY when Homework 6 tells you to:
#   bash codeHints/L06/friend.sh
root="$(cd "$(dirname "$0")/../.." && pwd)"
server="$root/practice/hw6_server.git"
[ -d "$server" ] || { echo "Run setup_hw6.sh first."; exit 1; }
if git --git-dir="$server" cat-file -e main:friend.txt 2>/dev/null; then
  echo "Your friend has already pushed. Nothing to do."; exit 0
fi

work="$(mktemp -d "${TMPDIR:-/tmp}/hw6friend.XXXXXX")"
trap 'rm -rf "$work"' EXIT
git clone -q "$server" "$work/friend" || exit 1
cd "$work/friend" || exit 1
git config user.name "Friend"
git config user.email "friend@example.com"
git config core.autocrlf false
git config commit.gpgsign false
printf 'hello from your friend\n' > friend.txt
git add friend.txt
GIT_AUTHOR_DATE="2024-09-03T09:00:00+0000" GIT_COMMITTER_DATE="2024-09-03T09:00:00+0000" git commit -q -m "Friend update"
git push -q origin main && echo "Your friend pushed a new commit to the server."
