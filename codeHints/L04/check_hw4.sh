#!/usr/bin/env bash
# Checker for Homework 4. Run from anywhere:  bash codeHints/L04/check_hw4.sh
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
HW="$ROOT/practice/hw4"
IDS="$ROOT/practice/.hw4_ids"
ANS="$ROOT/practice/hw4_answers.txt"
g() { git -C "$HW" "$@"; }
ans() { tr -d '\r' < "$ANS" | sed $'1s/^\xef\xbb\xbf//' | grep -E "^$1=" | head -1 | sed -E "s/^$1=//; s/[[:space:]]+\$//"; }
tip() { g rev-parse --verify -q "refs/heads/$1"; }

own_repo()    { [ -d "$HW/.git" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
on_main()     { [ "$(g symbolic-ref --short HEAD)" = "main" ]; }
branch_set()  { [ "$(g for-each-ref --format='%(refname:short)' refs/heads | sort | tr '\n' ' ')" = "experiment hotfix main shopping " ]; }
old_kept()    { [ "$(g rev-list --reverse main | sed -n 1p)" = "$(sed -n 1p "$IDS")" ] && [ "$(g rev-list --reverse main | sed -n 2p)" = "$(sed -n 2p "$IDS")" ]; }
shop_two()    { [ "$(g rev-list --count main..shopping)" = "2" ]; }
shop_msgs()   { [ "$(g log --reverse --format=%s main..shopping | tr '\n' '|')" = "Add shopping list|Add eggs|" ]; }
shop_base()   { [ "$(g merge-base main shopping)" = "$(sed -n 2p "$IDS")" ]; }
shop_file()   { [ "$(g show shopping:shopping.txt)" = "$(printf 'milk\neggs')" ]; }
main_three()  { [ "$(g rev-list --count main)" = "3" ]; }
main_msg()    { [ "$(g log -1 --format=%s main)" = "Add notes" ]; }
main_notes()  { g cat-file -e main:notes.txt; }
main_noshop() { ! g cat-file -e main:shopping.txt 2>/dev/null; }
exp_ok()      { [ "$(tip experiment)" = "$(sed -n 1p "$IDS")" ]; }
hot_ok()      { [ "$(tip hotfix)" = "$(g rev-parse main~1)" ]; }
clean()       { [ -z "$(g status --porcelain)" ]; }
a_count()     { [ "$(ans branches)" = "4" ]; }
a_word()      { case "$(ans branch-is | tr 'A-Z' 'a-z')" in pointer|label|reference|"movable pointer") return 0;; *) return 1;; esac; }

echo "Homework 4 checks (folder: $HW)"
check "setup: practice/hw4 is its own repository"           own_repo
check "4.1 shopping branch has exactly 2 commits beyond main" shop_two
check "4.2 shopping commits: 'Add shopping list', 'Add eggs'" shop_msgs
check "4.2 shopping.txt on shopping contains milk and eggs"  shop_file
check "4.1 shopping was started from the 'Add app file' commit" shop_base
check "4.3 main has three commits"                           main_three
check "4.3 newest commit on main is 'Add notes'"             main_msg
check "4.3 notes.txt exists on main"                         main_notes
check "4.3 shopping.txt does NOT exist on main"              main_noshop
check "4.4 branch 'experimnt' renamed; branches are exactly experiment, hotfix, main, shopping" branch_set
check "4.4 experiment still points to the first commit"      exp_ok
check "4.5 hotfix points to main~1 (the 'Add app file' commit)" hot_ok
check "4.6 you are on main with a clean working tree"        on_main
check "4.6 working directory clean"                          clean
check "4.6 original two commits untouched"                   old_kept
check "4.6 answers: branches=4"                              a_count
check "4.6 answers: branch-is=pointer"                       a_word
summary
