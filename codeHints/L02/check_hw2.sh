#!/usr/bin/env bash
# Checker for Homework 2. Run from anywhere:  bash codeHints/L02/check_hw2.sh
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
HW="$ROOT/practice/hw2"
g() { git -C "$HW" "$@"; }

own_repo()    { [ -d "$HW/.git" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
three_commits() { [ "$(g rev-list --count HEAD)" = "3" ]; }
msg_n()       { [ "$(g log --reverse --format=%s | sed -n "$1p")" = "$2" ]; }
files_of()    { g ls-tree -r --name-only "$1" | sort | tr '\n' ' '; }
commit_n()    { g rev-list --reverse HEAD | sed -n "$1p"; }
c1_files()    { [ "$(files_of "$(commit_n 1)")" = "README.md notes.txt " ]; }
c2_files()    { [ "$(files_of "$(commit_n 2)")" = "README.md notes.txt todo.txt " ]; }
c3_files()    { [ "$(files_of "$(commit_n 3)")" = ".gitignore README.md notes.txt todo.txt " ]; }
ignored()     { g check-ignore -q debug.log && g check-ignore -q secret.env && g check-ignore -q build/output.bin; }
secrets_out() { ! g ls-files --error-unmatch secret.env >/dev/null 2>&1; }
state_ok()    {
  [ "$(g status --short | sort | tr '\n' '|')" = " M todo.txt|M  notes.txt|" ]
}
answer_ok()   { tr -d '\r' < "$ROOT/practice/hw2_areas.txt" | grep -Eqi 'staging|index'; }

echo "Homework 2 checks (folder: $HW)"
check "setup: practice/hw2 is its own repository"          own_repo
check "2.1/2.2/2.3 exactly three commits"                   three_commits
check "2.1 first commit message is 'Add README and notes'"  msg_n 1 "Add README and notes"
check "2.1 first commit contains only README.md, notes.txt" c1_files
check "2.2 second commit message is 'Add todo list'"        msg_n 2 "Add todo list"
check "2.2 second commit adds todo.txt"                     c2_files
check "2.3 third commit message is 'Add .gitignore'"        msg_n 3 "Add .gitignore"
check "2.3 third commit adds only .gitignore"               c3_files
check "2.3 debug.log, secret.env and build/ are ignored"    ignored
check "2.3 secret.env was never committed"                  secrets_out
check "2.4 notes.txt staged, todo.txt modified, nothing else" state_ok
check "2.5 practice/hw2_areas.txt names the staging area"   answer_ok
summary
