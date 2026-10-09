#!/usr/bin/env bash
# Checker for Homework 1. Run from anywhere:  bash codeHints/L01/check_hw1.sh
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
HW="$ROOT/practice/hw1"

folder_exists() { [ -d "$HW" ]; }
own_repo()      {
  # hw1 must be the top level of its OWN repository (not the course repo above it).
  # --show-prefix is empty exactly when hw1 is the top level (works on any OS path style).
  [ -d "$HW/.git" ] && [ -z "$(git -C "$HW" rev-parse --show-prefix)" ]
}
branch_main()   { [ "$(git -C "$HW" symbolic-ref --short HEAD)" = "main" ]; }
hello_ok()      { [ "$(tr -d '\r' < "$HW/hello.txt")" = "Hello Git" ]; }
local_name()    { [ "$(git -C "$HW" config --local user.name)" = "Practice User" ]; }
local_email()   { [ "$(git -C "$HW" config --local user.email)" = "practice@example.com" ]; }
status_ok()     {
  grep -q "On branch main" "$HW/status.txt" &&
  grep -q "No commits yet" "$HW/status.txt" &&
  grep -q "hello.txt" "$HW/status.txt" &&
  grep -q "Untracked files" "$HW/status.txt"
}
no_commits()    { [ -z "$(git -C "$HW" rev-list --all 2>/dev/null)" ]; }
answer_ok()     { tr -d '\r' < "$HW/answer.txt" | grep -Eqx '\.git/?'; }

echo "Homework 1 checks (folder: $HW)"
check "1.1 folder practice/hw1 exists"                          folder_exists
check "1.2 hw1 is its own Git repository (has its own .git)"    own_repo
check "1.2 current branch is main"                              branch_main
check "1.3 hello.txt contains exactly: Hello Git"               hello_ok
check "1.4 local user.name is 'Practice User'"                  local_name
check "1.4 local user.email is practice@example.com"            local_email
check "1.5 status.txt shows main, no commits, untracked hello.txt" status_ok
check "1.6 answer.txt contains .git"                            answer_ok
check "    (no commits yet; committing comes in Lecture 2)"     no_commits
summary
