#!/usr/bin/env bash
# Checker for Homework 10. Run from anywhere:  bash codeHints/L10/check_hw10.sh
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
PR="$ROOT/practice"
HW="$PR/hw10"
IDS="$PR/.hw10_ids"
ANS="$PR/hw10_answers.txt"
g() { git -C "$HW" "$@"; }
ans() { tr -d '\r' < "$ANS" | sed $'1s/^\xef\xbb\xbf//' | grep -E "^$1=" | head -1 | sed -E "s/^$1=//; s/[[:space:]]+\$//"; }
id() { sed -n "$1p" "$IDS"; }   # 1 M3  2 L2  3-5 W1..W3  6 messy tree  7 first(history)  8 bad(Step 7)
lc() { echo "$1" | tr 'A-Z' 'a-z'; }

repo_ok()    { [ -d "$HW/.git" ] && [ -f "$IDS" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
main_same()  { [ "$(g rev-parse main)" = "$(id 1)" ]; }
resc_ok()    { [ "$(g rev-parse --verify -q refs/heads/rescued)" = "$(id 2)" ]; }
resc_msg()   { [ "$(g log -1 --format=%s rescued 2>/dev/null)" = "Important work" ]; }
messy_one()  { [ "$(g rev-list --count main..messy 2>/dev/null)" = "1" ]; }
messy_msg()  { [ "$(g log -1 --format=%s messy 2>/dev/null)" = "Add feature" ]; }
messy_tree() { [ "$(g rev-parse 'messy^{tree}' 2>/dev/null)" = "$(id 6)" ]; }
messy_old()  { for n in 3 4 5; do ! g merge-base --is-ancestor "$(id $n)" messy 2>/dev/null || return 1; done; }
bis_ans()    {
  a="$(ans bad-commit)"; [ "${#a}" -ge 7 ] || return 1
  [ "$(g rev-parse --verify -q "$a^{commit}" 2>/dev/null)" = "$(id 8)" ]
}
bis_done()   { [ ! -f "$HW/.git/BISECT_LOG" ] && [ ! -f "$HW/.git/BISECT_START" ]; }
urg_one()    { [ "$(g rev-list --count main..urgent 2>/dev/null)" = "1" ]; }
urg_msg()    { [ "$(g log -1 --format=%s urgent 2>/dev/null)" = "Fix urgent bug" ]; }
urg_fixed()  { [ "$(g show urgent:app.txt 2>/dev/null | tr -d '\r')" = "run the app" ]; }
on_main()    { [ "$(g symbolic-ref --short -q HEAD)" = "main" ]; }
stash_gone() { [ -z "$(g stash list)" ] && [ -z "$(g rev-parse --verify -q refs/stash)" ]; }
wip_back()   { grep -q 'work in progress' "$HW/notes.txt" 2>/dev/null; }
status_ok()  { [ "$(g status --short | grep -v -e '\.DS_Store' -e 'Thumbs\.db')" = " M notes.txt" ]; }
a_tree()     { a="$(lc "$(ans tree)")"; [ "${#a}" -ge 7 ] && [ "$(g rev-parse main^{tree})" != "" ] && case "$(g rev-parse 'main^{tree}')" in "$a"*) true;; *) false;; esac; }
a_hello()    { a="$(lc "$(ans hello)")"; [ "${#a}" -ge 7 ] && case "ce013625030ba8dba906f756967f9e9ca394464a" in "$a"*) true;; *) false;; esac; }
a_ref()      { a="$(lc "$(ans ref-file)")"; [ "${#a}" -ge 7 ] && case "$(g rev-parse main)" in "$a"*) true;; *) false;; esac; }

echo "Homework 10 checks (folder: $HW)"
if ! repo_ok; then
  echo "FAIL  setup: run  bash codeHints/L10/setup_hw10.sh  first"; FAIL_COUNT=$((FAIL_COUNT + 1))
else
  check "10.1 branch 'rescued' points at the lost commit 'Important work'" resc_ok
  check "10.1 its message is 'Important work'"                             resc_msg
  check "10.1 main itself was not changed (still on 'Add notes')"         main_same
  check "10.2 messy has exactly ONE commit beyond main"                    messy_one
  check "10.2 that commit is called 'Add feature'"                         messy_msg
  check "10.2 it contains exactly the same files as the three wip commits" messy_tree
  check "10.2 the three wip commits are no longer in messy"                messy_old
  check "10.3 answers: bad-commit=<ID of the first bad commit>"            bis_ans
  check "10.3 the bisect is finished (git bisect reset was run)"           bis_done
  check "10.4 urgent has exactly one commit beyond main"                   urg_one
  check "10.4 it is called 'Fix urgent bug' and app.txt says 'run the app'" urg_msg
  check "10.4 app.txt on urgent is fixed"                                  urg_fixed
  check "10.4 you are back on main"                                        on_main
  check "10.4 the stash is empty (popped)"                                 stash_gone
  check "10.4 your 'work in progress' line is back in notes.txt, uncommitted" wip_back
  check "10.4 git status shows only: ' M notes.txt'"                       status_ok
  check "10.5 answers: tree=<first 7 characters of main's tree ID>"        a_tree
  check "10.5 answers: hello=<first 7 characters of the hash of hello>"    a_hello
  check "10.5 answers: ref-file=<first 7 characters stored for main>"      a_ref
fi
summary
