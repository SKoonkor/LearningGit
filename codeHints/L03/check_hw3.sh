#!/usr/bin/env bash
# Checker for Homework 3. Run from anywhere:  bash codeHints/L03/check_hw3.sh
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
HW="$ROOT/practice/hw3"
IDS="$ROOT/practice/.hw3_ids"
ANS="$ROOT/practice/hw3_answers.txt"
g() { git -C "$HW" "$@"; }

nth()      { g rev-list --reverse HEAD | sed -n "$1p"; }
msg_n()    { [ "$(g log --reverse --format=%s | sed -n "$1p")" = "$2" ]; }
ans()      { tr -d '\r' < "$ANS" | sed $'1s/^\xef\xbb\xbf//' | grep -E "^$1=" | head -1 | sed -E "s/^$1=//; s/[[:space:]]+\$//"; }

own_repo()   { [ -d "$HW/.git" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
five()       { [ "$(g rev-list --count HEAD)" = "5" ]; }
old_kept()   {  # first three commits must be untouched (no history rewriting beyond the amend)
  [ "$(nth 1)" = "$(sed -n 1p "$IDS")" ] && [ "$(nth 2)" = "$(sed -n 2p "$IDS")" ] && [ "$(nth 3)" = "$(sed -n 3p "$IDS")" ]
}
amend_clean(){  # amended commit 4 must NOT contain the staged TODO line
  [ "$(g show "$(nth 4):notes.txt")" = "$(printf 'Pancakes need flour\nWhisk well')" ]
}
is_revert()  { [ "$(g rev-parse "$(nth 5)^")" = "$(nth 4)" ] && [ "$(g diff --name-only "$(nth 4)" "$(nth 5)")" = "list.txt" ]; }
list_back()  { [ "$(g show HEAD:list.txt)" = "$(printf 'milk\neggs')" ]; }
junk_gone()  { [ "$(cat "$HW/list.txt")" = "$(printf 'milk\neggs')" ]; }
work_kept()  { [ "$(cat "$HW/notes.txt")" = "$(printf 'Pancakes need flour\nWhisk well\nTODO: add syrup')" ]; }
status_ok()  { [ "$(g status --short)" = " M notes.txt" ]; }
a_fire()     {
  id="$(ans fireworks)"; [ "${#id}" -ge 7 ] || return 1
  [ "$(g rev-parse --verify -q "$id^{commit}")" = "$(sed -n 3p "$IDS")" ]
}
a_count()    { [ "$(ans commits)" = "4" ]; }
a_undo()     { [ "$(ans no-undo | tr 'A-Z' 'a-z' | sed -E 's/^git[[:space:]]+//')" = "restore" ]; }

echo "Homework 3 checks (folder: $HW)"
check "setup: practice/hw3 is its own repository"             own_repo
check "3.1 fireworks=<id of the 'Buy fireworks' commit>"      a_fire
check "3.1 commits=4"                                         a_count
check "3.2 list.txt junk line discarded (file back to HEAD)"  junk_gone
check "3.3/3.6 notes.txt keeps TODO line in working dir"      work_kept
check "3.3/3.6 status is exactly ' M notes.txt'"              status_ok
check "3.4 five commits in total"                             five
check "3.4 commit 4 message is 'Update notes'"                msg_n 4 "Update notes"
check "3.4 amended commit does not contain the TODO line"     amend_clean
check "3.5 commit 5 message is Revert \"Buy fireworks\""      msg_n 5 'Revert "Buy fireworks"'
check "3.5 commit 5 sits on commit 4 and changes only list.txt" is_revert
check "3.5 fireworks line is gone from list.txt in HEAD"      list_back
check "3.5 first three commits were not rewritten"            old_kept
check "3.6 no-undo=restore (answers file)"                    a_undo
summary
