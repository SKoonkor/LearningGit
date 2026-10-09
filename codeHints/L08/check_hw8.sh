#!/usr/bin/env bash
# Checker for Homework 8. Run from anywhere:  bash codeHints/L08/check_hw8.sh
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
PR="$ROOT/practice"
SERVER="$PR/hw8_server.git"
HW="$PR/hw8"
IDS="$PR/.hw8_ids"
ANS="$PR/hw8_answers.txt"
g() { git -C "$HW" "$@"; }
s() { git --git-dir="$SERVER" "$@"; }
ans() { tr -d '\r' < "$ANS" | sed $'1s/^\xef\xbb\xbf//' | grep -E "^$1=" | head -1 | sed -E "s/^$1=//; s/[[:space:]]+\$//"; }
id() { sed -n "$1p" "$IDS"; }   # 1 R1  2 R2  3 R3  4-8 F1..F5  9 H1
realdir() { (cd "$1" 2>/dev/null && pwd -P); }
blob() { s show "$1:$2" 2>/dev/null | tr -d '\r'; }

server_ok()  { [ -d "$SERVER" ] && [ -f "$IDS" ]; }
own_repo()   { [ -d "$HW/.git" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
cloned()     { own_repo && [ "$(realdir "$(g remote get-url origin)")" = "$(realdir "$SERVER")" ]; }
on_r3()      { s merge-base --is-ancestor "$(id 3)" feature; }                       # rebased onto main's newest commit
two_new()    { [ "$(s rev-list --count "$(id 3)..feature")" = "2" ]; }
msgs()       { [ "$(s log --reverse --format=%s "$(id 3)..feature" | tr '\n' '|')" = "Add greeting|Add farewell|" ]; }
old_gone()   { for n in 4 5 6 7 8; do ! s merge-base --is-ancestor "$(id $n)" feature 2>/dev/null || return 1; done; }
greet_ok()   { [ "$(blob feature greeting.txt)" = "$(printf 'Hello, world\nWelcome!')" ]; }
fare_ok()    { [ "$(blob feature farewell.txt)" = "$(printf 'Goodbye\nSee you soon')" ]; }
readme_ok()  {
  t="$(blob feature README.md)"
  echo "$t" | grep -qx 'Maintained by the team.' && echo "$t" | grep -qx 'Usage: run the greeter.' && ! echo "$t" | grep -Eq '^(<<<<<<<|=======|>>>>>>>)'
}
main_cp()    { [ "$(s log -1 --format=%s main)" = "Fix crash in app" ] && [ "$(blob main app.txt)" = "print the greeting safely" ]; }
main_lin()   { [ "$(s rev-list --count main)" = "4" ] && [ "$(s rev-list --merges --count main)" = "0" ] && s merge-base --is-ancestor "$(id 3)" main; }
cp_new_id()  { [ "$(s rev-parse main)" != "$(id 9)" ] && ! s merge-base --is-ancestor "$(id 9)" main; }   # a copy, not the original commit
hot_kept()   { [ "$(s rev-parse hotfix)" = "$(id 9)" ]; }
in_sync()    { own_repo && [ "$(g rev-parse refs/remotes/origin/feature)" = "$(s rev-parse feature)" ]; }
clean()      { own_repo && [ -z "$(g status --porcelain | grep -v -e '\.DS_Store' -e 'Thumbs\.db')" ] && [ -z "$(g rev-parse -q --verify REBASE_HEAD)" ] && [ ! -d "$HW/.git/rebase-merge" ] && [ ! -d "$HW/.git/rebase-apply" ]; }
a_shared()   { [ "$(ans shared-rebase | tr 'A-Z' 'a-z')" = "no" ]; }
a_safer()    { [ "$(ans safer-force | tr 'A-Z' 'a-z' | sed -E 's/^--//; s/^git push //')" = "force-with-lease" ]; }
a_ids()      { [ "$(ans new-ids | tr 'A-Z' 'a-z')" = "rebase" ]; }

echo "Homework 8 checks (folder: $HW)"
if ! server_ok; then
  echo "FAIL  setup: run  bash codeHints/L08/setup_hw8.sh  first"; FAIL_COUNT=$((FAIL_COUNT + 1))
else
  check "8.1 practice/hw8 is a clone of practice/hw8_server.git"           cloned
  check "8.2 server's feature sits on top of main's newest commit"         on_r3
  check "8.2 feature has exactly two commits beyond main"                  two_new
  check "8.3 their messages are 'Add greeting' then 'Add farewell'"        msgs
  check "8.3 none of the five messy original commits is left"              old_gone
  check "8.3 greeting.txt = Hello, world / Welcome!"                       greet_ok
  check "8.3 farewell.txt = Goodbye / See you soon"                        fare_ok
  check "8.3 README.md has BOTH lines and no conflict markers"             readme_ok
  check "8.4 your feature and the server's feature are identical (pushed)" in_sync
  check "8.5 main's newest commit is 'Fix crash in app' with the fixed app.txt" main_cp
  check "8.5 main is a straight line of 4 commits (no merge commit)"       main_lin
  check "8.5 it is a COPY of the hotfix commit (new ID, not a merge)"      cp_new_id
  check "8.5 the hotfix branch itself is untouched"                        hot_kept
  check "8.6 answers: shared-rebase=no"                                    a_shared
  check "8.6 answers: safer-force=force-with-lease"                        a_safer
  check "8.6 answers: new-ids=rebase"                                      a_ids
  check "8.6 no rebase left unfinished and the working directory is clean" clean
fi
summary
