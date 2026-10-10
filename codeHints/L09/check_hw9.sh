#!/usr/bin/env bash
# Checker for Homework 9. Run from anywhere:  bash codeHints/L09/check_hw9.sh
# Part A (9.1-9.8) uses the local "server" folder and needs no network.
# Part B (optional, 9.9-9.12) checks your real GitHub repository through GitHub's public API.
. "$(dirname "$0")/../common.sh"

ROOT="$(cd "$(dirname "$0")/../.." && pwd -P)"
PR="$ROOT/practice"
SERVER="$PR/hw9_server.git"
HW="$PR/hw9"
IDS="$PR/.hw9_ids"
ANS="$PR/hw9_answers.txt"
g() { git -C "$HW" "$@"; }
s() { git --git-dir="$SERVER" "$@"; }
ans() { tr -d '\r' < "$ANS" | sed $'1s/^\xef\xbb\xbf//' | grep -E "^$1=" | head -1 | sed -E "s/^$1=//; s/[[:space:]]+\$//"; }
id() { sed -n "$1p" "$IDS"; }   # 1 = README commit, 2 = greeter+test commit
realdir() { (cd "$1" 2>/dev/null && pwd -P); }
blob() { s show "main:$1" 2>/dev/null | tr -d '\r'; }

server_ok()  { [ -d "$SERVER" ] && [ -f "$IDS" ]; }
own_repo()   { [ -d "$HW/.git" ] && [ -z "$(g rev-parse --show-prefix)" ]; }
cloned()     { own_repo && [ "$(realdir "$(g remote get-url origin)")" = "$(realdir "$SERVER")" ]; }
# the project's own test must pass on what the server's main contains (this is what CI would run)
tests_pass() {
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/hw9chk.XXXXXX")" || return 1
  s archive main | tar -x -C "$tmp" 2>/dev/null
  ( cd "$tmp" && bash test.sh >/dev/null 2>&1 ); r=$?
  rm -rf "$tmp"; return $r
}
wf_files()   { s ls-tree -r --name-only main | grep -E '^\.github/workflows/[^/]+\.ya?ml$'; }
wf()         { for f in $(wf_files); do s show "main:$f" | tr -d '\r'; echo; done; }   # text of all workflow files
wf_exists()  { [ -n "$(wf_files)" ]; }
wf_notabs()  { ! wf | grep -q "$(printf '\t')"; }
wf_name()    { wf | grep -Eq '^name:[[:space:]]*[^[:space:]]'; }
wf_on()      { wf | grep -Eq '^on:' && wf | grep -Eq '^(on:.*(push|pull_request)|[[:space:]]+(push|pull_request):)'; }
wf_jobs()    { wf | grep -Eq '^jobs:' && wf | grep -Eq '^[[:space:]]+runs-on:[[:space:]]*ubuntu'; }
wf_checkout(){ wf | grep -Eq '^[[:space:]]*-?[[:space:]]*uses:[[:space:]]*actions/checkout@'; }
wf_runtest() { wf | grep -Eq '^[[:space:]]*(-[[:space:]]*)?(run:[[:space:]]*)?((bash|sh)[[:space:]]+(\./)?|\./)test\.sh([[:space:]]|$)'; }
issue_tpl()  {
  t="$(blob .github/ISSUE_TEMPLATE/bug_report.md | sed $'1s/^\xef\xbb\xbf//' | sed -E 's/[[:space:]]+$//')"
  [ -n "$t" ] || return 1
  [ "$(echo "$t" | head -1)" = "---" ] || return 1
  fm="$(echo "$t" | awk 'NR==1{next} /^---$/{exit} {print}')"          # lines between the two ---
  echo "$fm" | grep -Eq '^name:' && echo "$fm" | grep -Eq '^about:' && echo "$t" | grep -Eq '^#'
}
pr_tpl()     { blob .github/pull_request_template.md | grep -Eq '^[[:space:]]*-[[:space:]]\[[ xX]\]'; }
closes()     { s log --format=%B main | grep -Eiq '(^|[^a-z])(close[sd]?|fix(e[sd])?|resolve[sd]?):?[[:space:]]+#1([^0-9]|$)'; }
greet_fixed(){ [ "$(blob greet.sh | grep -c 'Hello, world')" -ge 1 ]; }
seed_kept()  { s merge-base --is-ancestor "$(id 1)" main && s merge-base --is-ancestor "$(id 2)" main; }
tag_light()  { [ "$(s cat-file -t refs/tags/v0.1.0 2>/dev/null)" = "commit" ] && [ "$(s rev-parse refs/tags/v0.1.0)" = "$(id 1)" ]; }
tag_annot()  { [ "$(s cat-file -t refs/tags/v1.0.0 2>/dev/null)" = "tag" ]; }
tag_msg()    { [ -n "$(s for-each-ref --format='%(contents:subject)' refs/tags/v1.0.0 2>/dev/null)" ]; }
tag_on_fix() { c="$(s rev-parse 'refs/tags/v1.0.0^{commit}' 2>/dev/null)"; [ -n "$c" ] && s merge-base --is-ancestor "$c" main && [ "$(s show "$c:greet.sh" 2>/dev/null | grep -c 'Hello, world')" -ge 1 ]; }
a_next()     { [ "$(ans next-bugfix)" = "1.0.1" ]; }
a_closes()   { [ "$(ans issue-closes-when | tr 'A-Z' 'a-z')" = "merged" ]; }
clean()      { own_repo && [ -z "$(g status --porcelain | grep -v -e '\.DS_Store' -e 'Thumbs\.db')" ]; }

echo "Homework 9, part A (local server; no network needed)"
if ! server_ok; then
  echo "FAIL  setup: run  bash codeHints/L09/setup_hw9.sh  first"; FAIL_COUNT=$((FAIL_COUNT + 1))
else
  check "9.1 practice/hw9 is a clone of practice/hw9_server.git"            cloned
  check "9.3 the project's test passes on the server's main (greet.sh fixed)" tests_pass
  check "9.3 greet.sh prints Hello, world"                                  greet_fixed
  check "9.4 a commit message on main says Closes #1 (or Fixes/Resolves)"   closes
  check "9.5 a workflow file exists in .github/workflows/ on main"          wf_exists
  check "9.5 workflow: no tab characters (YAML forbids them)"               wf_notabs
  check "9.5 workflow: has a name:"                                         wf_name
  check "9.5 workflow: runs on push or pull_request"                        wf_on
  check "9.5 workflow: jobs: with runs-on: ubuntu-..."                      wf_jobs
  check "9.5 workflow: a step uses actions/checkout@..."                    wf_checkout
  check "9.5 workflow: a step runs: bash test.sh"                           wf_runtest
  check "9.6 issue template .github/ISSUE_TEMPLATE/bug_report.md (front matter with name/about, a heading)" issue_tpl
  check "9.6 pull_request_template.md has a checklist item (- [ ])"         pr_tpl
  check "9.7 lightweight tag v0.1.0 on the first commit is on the server"   tag_light
  check "9.7 annotated tag v1.0.0 (with a message) is on the server"        tag_annot
  check "9.7 the v1.0.0 tag message is not empty"                           tag_msg
  check "9.7 v1.0.0 points at a commit on main that contains the fix"       tag_on_fix
  check "9.8 answers: next-bugfix=1.0.1"                                    a_next
  check "9.8 answers: issue-closes-when=merged"                             a_closes
  check "9.8 the two original commits are untouched"                    seed_kept
  check "9.8 working directory clean"                                       clean
fi

# ---------- part B: your real GitHub repository (optional) ----------
echo
echo "Homework 9, part B (optional: your own public GitHub repository)"
repo="$( [ -f "$ANS" ] && ans repo )"
if [ -z "$repo" ]; then
  skip "no 'repo=owner/name' line in hw9_answers.txt: part B not started (optional)"
else
  num="$(ans issue)"
  api() { curl -sL -m 15 -w '\n%{http_code}' "https://api.github.com/repos/$repo${1:+/$1}" 2>/dev/null; }
  fmt_ok() { echo "$repo" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$'; }
  check "9.9 hw9_answers.txt has repo=<owner>/<name>" fmt_ok
  lc() { echo "$1" | tr 'A-Z' 'a-z'; }
  has_remote() {   # one of the remotes of practice/hw9 must be the repository named in the answers
    own_repo || return 1
    for u in $(g remote -v | awk '{print $2}' | sort -u); do
      r="$(echo "$u" | sed -E 's#^.*github\.com[:/]##; s#/$##; s#\.git$##; s#/$##')"
      [ "$(lc "$r")" = "$(lc "$repo")" ] && return 0
    done
    return 1
  }
  not_found() { false; }
  if fmt_ok; then
    check "9.9 a remote of practice/hw9 points at $repo (git remote add github <address>)" has_remote
    r="$(api "")"; code="$(echo "$r" | tail -1)"
    if [ "$code" = "200" ]; then
      check "9.9 repository $repo exists and is public" true
      # --- issue
      if ! echo "$num" | grep -Eq '^[0-9]+$'; then
        check "9.10 hw9_answers.txt has issue=<number> (add it after step 9.10)" not_found
      else
        r="$(api "issues/$num")"; code="$(echo "$r" | tail -1)"
        if [ "$code" = "200" ]; then
          is_issue()     { ! echo "$r" | grep -Eq '^  "pull_request":'; }
          issue_closed() { echo "$r" | grep -Eq '^  "state": *"closed"'; }
          check "9.10 #$num is an issue (not a pull request)" is_issue
          check "9.10 issue #$num is closed (by your merged pull request)" issue_closed
        elif [ "$code" = "404" ]; then
          check "9.10 issue #$num cannot be found in $repo" not_found
        else
          skip "9.10 GitHub did not answer (HTTP $code: rate limit or network): issue not verified"
        fi
      fi
      # --- release
      r="$(api "releases/tags/v1.0.0")"; code="$(echo "$r" | tail -1)"
      if [ "$code" = "200" ]; then check "9.11 a GitHub release exists for tag v1.0.0" true
      elif [ "$code" = "404" ]; then check "9.11 no GitHub release for tag v1.0.0 (create it on the Releases page)" not_found
      else skip "9.11 GitHub did not answer (HTTP $code): release not verified"; fi
      # --- CI
      r="$(api "actions/runs?per_page=1&branch=main")"; code="$(echo "$r" | tail -1)"
      if [ "$code" = "200" ]; then
        status="$(echo "$r" | grep -m1 '"status"' | tr -d ' ,"' | sed 's/status://')"
        concl="$(echo "$r" | grep -m1 '"conclusion"' | tr -d ' ,"' | sed 's/conclusion://')"
        if [ -z "$status" ]; then
          check "9.12 there is no Actions run on main yet (push the workflow and wait)" not_found
        elif [ "$status" != "completed" ] || [ "$concl" = "null" ]; then
          skip "9.12 the latest run on main is still $status: wait until it finishes, then run the checker again"
        else
          ci_green() { [ "$concl" = "success" ]; }
          check "9.12 the latest Actions run on main is green (conclusion: success; yours: ${concl:-none})" ci_green
        fi
      else
        skip "9.12 could not read the Actions runs (HTTP $code): not verified"
      fi
    elif [ "$code" = "404" ]; then
      check "9.9 GitHub cannot find $repo (spelling? the repository must be PUBLIC)" not_found
    else
      skip "9.9-9.12 could not reach GitHub's public API (HTTP $code: no network, or rate limit): part B was NOT verified"
    fi
  fi
fi
summary
