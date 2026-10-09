#!/usr/bin/env bash
# Shared helpers for all checkers. Source this file: . "$(dirname "$0")/../common.sh"
# Works with bash 3.2 (macOS default) and Git Bash on Windows.

# Sorting and message text must not depend on the user's language settings.
export LC_ALL=C

PASS_COUNT=0
FAIL_COUNT=0

# check "description" command...   -> runs the command quietly; PASS if exit code 0
check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS  $desc"; PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL  $desc"; FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# skip "description"   -> an optional check that could not run (not counted as a failure)
skip() { echo "SKIP  $1"; }

# summary: print totals and exit non-zero if anything failed
summary() {
  echo
  echo "$PASS_COUNT passed, $FAIL_COUNT failed"
  [ "$FAIL_COUNT" -eq 0 ] && echo "All checks passed. You may now open the solutions." && exit 0
  echo "Fix the FAIL lines above and run the checker again."
  exit 1
}

# practice_dir: folder where sandbox repos live (<course root>/practice)
practice_dir() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  echo "$here/../practice"
}
