#!/usr/bin/env bash
# Checker for Homework 0. Run from anywhere:  bash codeHints/L00/check_hw0.sh
. "$(dirname "$0")/../common.sh"

git_ok()      { command -v git; }
git_version() {
  # need Git >= 2.28 so that init.defaultBranch exists
  local v major minor
  v="$(git --version | sed -E 's/[^0-9]*([0-9]+)\.([0-9]+).*/\1 \2/')"
  set -- $v; major=$1; minor=$2
  [ "$major" -gt 2 ] || { [ "$major" -eq 2 ] && [ "$minor" -ge 28 ]; }
}
name_set()    { [ -n "$(git config --global user.name)" ]; }
email_set()   { [ -n "$(git config --global user.email)" ]; }
email_shape() { git config --global user.email | grep -Eq '^[^@ ]+@[^@ ]+\.[^@ ]+$'; }
branch_main() { [ "$(git config --global init.defaultBranch)" = "main" ]; }

echo "Homework 0 checks"
check "0.1 git is installed"                       git_ok
check "0.1 git version is 2.28 or newer"           git_version
check "0.2 user.name is set (global)"              name_set
check "0.2 user.email is set (global)"             email_set
check "0.2 user.email looks like an email address" email_shape
check "0.3 init.defaultBranch is main"             branch_main
summary
