#!/usr/bin/env bash
# Checker for Homework 7. Run from anywhere:  bash codeHints/L07/check_hw7.sh
# Part A (7.1-7.6) uses the local "server" folder and needs no network.
# Part B (optional, 7.7-7.9) is your real pull request pair exercise on GitHub; it is skipped
# if you have not started it. It looks your pull request up through GitHub's public API.
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
PR="$ROOT/practice"
SERVER="$PR/hw7_server.git"
HW="$PR/hw7"
IDS="$PR/.hw7_ids"
ANS="$PR/hw7_answers.txt"
g() { git -C "$HW" "$@"; }
s() { git --git-dir="$SERVER" "$@"; }
ans() { tr -d '\r' < "$1" | sed $'1s/^\xef\xbb\xbf//' | grep -E "^$2=" | head -1 | sed -E "s/^$2=//; s/[[:space:]]+\$//"; }
id() { sed -n "$1p" "$IDS"; }   # 1=README 2=app 3=greeting 4=document
realdir() { (cd "$1" 2>/dev/null && pwd -P); }

server_ok()   { [ -d "$SERVER" ] && [ -f "$IDS" ]; }
own_repo()    { [ -d "$HW/.git" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
cloned()      { own_repo && [ "$(realdir "$(g remote get-url origin)")" = "$(realdir "$SERVER")" ]; }
a_commits()   { [ "$(ans "$ANS" commits)" = "2" ]; }
a_typo()      { [ "$(ans "$ANS" typo-in)" = "greeting.txt" ]; }
a_button()    { [ "$(ans "$ANS" merge-button | tr 'A-Z' 'a-z')" = "merge" ]; }
orig_kept()   { for n in 1 2 3 4; do s merge-base --is-ancestor "$(id $n)" main || return 1; done; }
fixed()       { [ "$(s show main:greeting.txt | tr -d '\r')" = "Hello, world" ]; }
fix_msg()     { s log --format=%s main | grep -qx 'Fix typo in greeting'; }
tip_merge()   { [ "$(s rev-list --parents -n 1 main | wc -w | tr -d ' ')" = "3" ]; }
no_remote_br(){ [ -z "$(s rev-parse --verify -q refs/heads/teammate-feature)" ]; }
no_local_br() { own_repo && [ -z "$(g branch --list teammate-feature)" ]; }
in_sync()     { own_repo && [ "$(g rev-parse main)" = "$(s rev-parse main)" ]; }
clean()       { own_repo && [ -z "$(g status --porcelain | grep -v -e '\.DS_Store' -e 'Thumbs\.db')" ]; }

echo "Homework 7, part A (local server; no network needed)"
if ! server_ok; then
  echo "FAIL  setup: run  bash codeHints/L07/setup_hw7.sh  first"; FAIL_COUNT=$((FAIL_COUNT + 1))
else
  check "7.1 practice/hw7 is a clone of practice/hw7_server.git"          cloned
  check "7.2 answers: commits=2"                                         a_commits
  check "7.2 answers: typo-in=greeting.txt"                              a_typo
  check "7.3 your fix commit 'Fix typo in greeting' is on the server's main" fix_msg
  check "7.3 greeting.txt on the server's main says: Hello, world"       fixed
  check "7.4 the newest commit on the server's main is a merge commit"   tip_merge
  check "7.4 the teammate's two commits and the originals are untouched" orig_kept
  check "7.4 your main equals the server's main"                         in_sync
  check "7.5 teammate-feature is deleted on the server"                  no_remote_br
  check "7.5 teammate-feature is deleted in your clone"                  no_local_br
  check "7.6 answers: merge-button=merge"                                a_button
  check "7.6 working directory clean"                                    clean
fi

# ---------- part B: real pull requests with a friend (optional) ----------
PB="$PR/hw7_pr"
BANS="$PR/hw7_pr_answers.txt"
echo
echo "Homework 7, part B (optional: real pull requests on GitHub with a friend)"
if [ ! -d "$PB/.git" ] && [ ! -f "$BANS" ]; then
  skip "practice/hw7_pr not found: part B not started (optional)"
else
  p() { git -C "$PB" "$@"; }
  b_dir()    { [ -d "$PB/.git" ] && p remote get-url origin | grep -Eq 'github\.com[:/]'; }
  b_clean()  { [ -d "$PB/.git" ] && [ -z "$(p status --porcelain | grep -v -e '\.DS_Store' -e 'Thumbs\.db')" ]; }
  b_main()   { [ "$(p symbolic-ref --short HEAD 2>/dev/null)" = "main" ]; }
  b_fmt()    { echo "$(ans "$BANS" my-pr)" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+$'; }
  repo_of()  { sed -E 's#^.*github\.com[:/]##; s#/$##; s#\.git$##; s#/$##'; }
  b_fork()   { p remote get-url upstream >/dev/null 2>&1; }
  check "7.7/7.8 practice/hw7_pr is a clone whose origin is on github.com"    b_dir
  check "7.9 you are back on main"                                       b_main
  check "7.9 working directory clean"                                      b_clean
  check "7.9 hw7_pr_answers.txt: my-pr=<owner>/<repo>#<number>"            b_fmt
  if b_fmt; then
    mypr="$(ans "$BANS" my-pr)"; repo="${mypr%#*}"; num="${mypr##*#}"
    # the pull request must belong to the repository you cloned (collaborator route),
    # or to your 'upstream' (fork route; then 'upstream' is required)
    origin_repo="$(p remote get-url origin 2>/dev/null | repo_of)"
    upstream_repo="$(p remote get-url upstream 2>/dev/null | repo_of)"
    lc() { echo "$1" | tr 'A-Z' 'a-z'; }
    route_ok() {
      # fork route (an 'upstream' remote exists): the PR must be in the ORIGINAL repository, not in your own fork
      if [ -n "$upstream_repo" ]; then [ "$(lc "$repo")" = "$(lc "$upstream_repo")" ]; return; fi
      [ "$(lc "$repo")" = "$(lc "$origin_repo")" ]
    }
    check "7.9 your pull request is in the repository you cloned (collaborator route) or in your 'upstream' (fork route)" route_ok
    body="$(curl -sL -m 15 -w '\n%{http_code}' "https://api.github.com/repos/$repo/pulls/$num" 2>/dev/null)"
    code="$(echo "$body" | tail -1)"
    if [ "$code" = "200" ]; then
      pr_merged() { echo "$body" | grep -Eq '^  "merged": *true'; }
      check "7.9 your pull request $mypr is merged"                        pr_merged
    elif [ "$code" = "404" ]; then
      not_found() { false; }
      check "7.9 GitHub cannot find $mypr (check the spelling and number; the repository must be PUBLIC)" not_found
    else
      skip "7.9 could not reach GitHub's public API (no network, rate limit, or a moved repository): the merged-check was NOT verified"
    fi
  fi
  if b_fork; then
    up_ok() { [ "$(p remote get-url upstream | grep -Ec 'github\.com[:/]')" = "1" ]; }
    check "7.8 (fork route) the remote 'upstream' points at the original repository on github.com" up_ok
  fi
fi
summary
