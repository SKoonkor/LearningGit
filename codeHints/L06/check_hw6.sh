#!/usr/bin/env bash
# Checker for Homework 6. Run from anywhere:  bash codeHints/L06/check_hw6.sh
# Part A (tasks 6.1-6.7) uses the local "server" folder and needs no network.
# Part B (optional, tasks 6.8-6.10) uses your own GitHub repo; it is skipped if you have not started it.
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
PR="$ROOT/practice"
SERVER="$PR/hw6_server.git"
HW="$PR/hw6"
IDS="$PR/.hw6_ids"
ANS="$PR/hw6_answers.txt"
g() { git -C "$HW" "$@"; }
s() { git --git-dir="$SERVER" "$@"; }
ans() { tr -d '\r' < "$ANS" | sed $'1s/^\xef\xbb\xbf//' | grep -E "^$1=" | head -1 | sed -E "s/^$1=//; s/[[:space:]]+\$//"; }
realdir() { (cd "$1" 2>/dev/null && pwd -P); }

server_ok()   { [ -d "$SERVER" ] && [ -f "$IDS" ]; }
own_repo()    { [ -d "$HW/.git" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
cloned()      { own_repo && [ "$(realdir "$(g remote get-url origin)")" = "$(realdir "$SERVER")" ]; }
seed_kept()   { s merge-base --is-ancestor "$(sed -n 1p "$IDS")" main && s merge-base --is-ancestor "$(sed -n 2p "$IDS")" main; }
mine_on_srv() { [ "$(s log --format=%s main | grep -cx 'Add my work')" = "1" ] && s cat-file -e main:mine.txt; }
friend_loc()  { own_repo && g log --format=%s main | grep -qx 'Friend update'; }
one_merge()   { own_repo && [ "$(g rev-list --merges --count main)" = "1" ]; }
in_sync()     { own_repo && [ "$(g rev-parse main)" = "$(s rev-parse main)" ]; }
feat_srv()    { own_repo && [ -n "$(s rev-parse --verify -q refs/heads/feature)" ] && [ "$(s rev-parse refs/heads/feature)" = "$(g rev-parse refs/heads/feature)" ]; }
feat_msg()    { [ "$(s log -1 --format=%s refs/heads/feature)" = "Add feature file" ]; }
feat_track()  { own_repo && [ "$(g config branch.feature.remote)" = "origin" ] && [ "$(g config branch.feature.merge)" = "refs/heads/feature" ]; }
clean()       { own_repo && [ -z "$(g status --porcelain | grep -v -e '\.DS_Store' -e 'Thumbs\.db')" ]; }
a_remote()    { [ "$(ans remote)" = "origin" ]; }
a_ahead()     { [ "$(ans ahead)" = "1" ]; }
a_fetch()     { [ "$(ans no-merge | tr 'A-Z' 'a-z' | sed -E 's/^git[[:space:]]+//')" = "fetch" ]; }

echo "Homework 6, part A (local server; no network needed)"
if ! server_ok; then
  echo "FAIL  setup: run  bash codeHints/L06/setup_hw6.sh  first"; FAIL_COUNT=$((FAIL_COUNT + 1))
else
  check "6.1 practice/hw6 is a clone of practice/hw6_server.git"     cloned
  check "6.2 answers: remote=origin"                                 a_remote
  check "6.3 answers: ahead=1"                                       a_ahead
  check "6.3 your commit 'Add my work' (with mine.txt) is on the server" mine_on_srv
  check "6.4 your friend's commit 'Friend update' is in your history" friend_loc
  check "6.4 exactly one merge commit in main (from pulling)"        one_merge
  check "6.5 your main and the server's main are identical"          in_sync
  check "6.5 the original two commits are untouched"                 seed_kept
  check "6.6 branch 'feature' exists on the server, same commit as yours" feat_srv
  check "6.6 the feature commit is 'Add feature file'"               feat_msg
  check "6.6 feature tracks origin/feature (pushed with -u)"         feat_track
  check "6.7 answers: no-merge=fetch"                                a_fetch
  check "6.7 working directory clean"                                clean
fi

# ---------- part B: your own GitHub repository (optional) ----------
GH="$PR/hw6_github"
echo
echo "Homework 6, part B (optional: your own GitHub repository)"
if [ ! -d "$GH/.git" ]; then
  skip "practice/hw6_github not found: part B not started (optional)"
else
  gh() { git -C "$GH" "$@"; }
  gh_url()   { gh remote get-url origin | grep -Eq 'github\.com[:/]'; }
  gh_track() { [ "$(gh config branch.main.remote)" = "origin" ] && [ "$(gh config branch.main.merge)" = "refs/heads/main" ]; }
  gh_readme(){ [ -f "$GH/README.md" ]; }
  gh_two()   { [ "$(gh rev-list --count HEAD)" -ge 2 ]; }
  gh_clean() { [ -z "$(gh status --porcelain | grep -v -e '\.DS_Store' -e 'Thumbs\.db')" ]; }
  check "6.8 practice/hw6_github has origin pointing at github.com"  gh_url
  check "6.8 it contains README.md"                                  gh_readme
  check "6.8 main tracks origin/main (pushed with -u)"               gh_track
  check "6.10 at least two commits (your first one plus the one you pulled or made later)" gh_two
  check "6.10 working directory clean"                               gh_clean
  remote_sha="$(GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=10' gh ls-remote --heads origin main 2>/dev/null | cut -f1)"
  if [ -z "$remote_sha" ]; then
    skip "6.9 could not reach GitHub (no network or no login): in-sync check skipped"
  else
    gh_sync() { [ "$remote_sha" = "$(gh rev-parse main)" ]; }
    check "6.9/6.10 your local main is identical to GitHub's main"   gh_sync
  fi
fi
summary
