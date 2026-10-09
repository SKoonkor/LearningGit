#!/usr/bin/env bash
# Checker for Homework 5. Run from anywhere:  bash codeHints/L05/check_hw5.sh
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
HW="$ROOT/practice/hw5"
IDS="$ROOT/practice/.hw5_ids"
ANS="$ROOT/practice/hw5_answers.txt"
g() { git -C "$HW" "$@"; }
ans() { tr -d '\r' < "$ANS" | sed $'1s/^\xef\xbb\xbf//' | grep -E "^$1=" | head -1 | sed -E "s/^$1=//; s/[[:space:]]+\$//"; }
id() { sed -n "$1p" "$IDS"; }   # 1=README 2=menu 3=drinks 4=desserts 5=spicy 6=vegan

own_repo()   { [ -d "$HW/.git" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
on_main()    { own_repo && [ "$(g symbolic-ref --short HEAD)" = "main" ]; }
only_main()  { own_repo && [ "$(g for-each-ref --format='%(refname:short)' refs/heads | tr '\n' ' ')" = "main " ]; }
clean()      { own_repo && [ -z "$(g status --porcelain | grep -v -e '\.DS_Store' -e 'Thumbs\.db')" ]; }
all_in()     { own_repo && for n in 1 2 3 4 5 6; do g merge-base --is-ancestor "$(id $n)" main || return 1; done; }
three_merges(){ [ "$(g rev-list --merges --count main)" = "3" ]; }
two_parents(){ for m in $(g rev-list --merges main); do [ "$(g rev-list --parents -n 1 "$m" | wc -w | tr -d ' ')" = "3" ] || return 1; done; }
ff_first()   { [ "$(g rev-parse "$(g rev-list --merges --reverse main | sed -n 1p)^1")" = "$(id 3)" ]; }
tip_merge()  { [ "$(g rev-list --parents -n 1 main | wc -w | tr -d ' ')" = "3" ]; }
files_ok()   { [ "$(g ls-tree -r --name-only main | tr '\n' ' ')" = "README.md desserts.txt drinks.txt menu.txt " ]; }
no_markers() { own_repo && ! g grep -q -E '^(<<<<<<<|=======|>>>>>>>)' main -- 2>/dev/null; }
menu_ok()    {
  l1="$(g show main:menu.txt | tr -d '\r' | sed -n 1p)"; l2="$(g show main:menu.txt | tr -d '\r' | sed -n 2p)"
  case "$l1" in *spicy*) ;; *) return 1;; esac
  case "$l1" in *vegan*) ;; *) return 1;; esac
  [ "$l2" = "Pasta" ]
}
order_ok()   { own_repo && g merge-base --is-ancestor "$(id 5)" "main^1" 2>/dev/null; }   # spicy merged before the vegan conflict merge
a_above()    { [ "$(ans above | tr 'A-Z' 'a-z')" = "spicy" ]; }
a_merges()   { [ "$(ans merge-commits)" = "3" ]; }

echo "Homework 5 checks (folder: $HW)"
check "setup: practice/hw5 is its own repository"                 own_repo
check "5.1 'Add drinks' was fast-forwarded (first merge commit sits on it)" ff_first
check "5.2-5.4 exactly three merge commits in main"               three_merges
check "5.2-5.4 every merge commit has two parents"                two_parents
check "5.4 the newest commit on main is a merge commit"           tip_merge
check "5.1-5.4 all six original commits are in main's history"    all_in
check "5.1-5.4 main contains README, menu, drinks and desserts files" files_ok
check "5.3/5.4 spicy was merged BEFORE vegan (as the task order says)" order_ok
check "5.4 menu.txt: first line mentions spicy AND vegan, second is Pasta" menu_ok
check "5.4 no conflict markers left in the committed files"       no_markers
check "5.4 working directory clean (merge finished)"              clean
check "5.5 the four merged branches are deleted (only main left)" only_main
check "5.5 you are on main"                                       on_main
check "5.6 answers: above=spicy"                                  a_above
check "5.6 answers: merge-commits=3"                              a_merges
summary
