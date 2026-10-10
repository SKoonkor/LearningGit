#!/usr/bin/env bash
# Setup for Homework 2. Run from the course folder:  bash codeHints/L02/setup_hw2.sh
# Creates practice/hw2: a repository with five untracked files, one folder, and NO commits.
# Use  --reset  to delete an existing practice/hw2 and start again.
root="$(cd "$(dirname "$0")/../.." && pwd)"
hw="$root/practice/hw2"

if [ -e "$hw" ]; then
  if [ "$1" = "--reset" ] && [ "$(basename "$hw")" = "hw2" ] && [ "$(basename "$(dirname "$hw")")" = "practice" ]; then
    rm -rf "$hw"
  else
    echo "practice/hw2 already exists. To start over run:"
    echo "  bash codeHints/L02/setup_hw2.sh --reset"
    exit 1
  fi
fi

mkdir -p "$hw/build"
cd "$hw" || exit 1
git init -q -b main || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }
git config --local user.name "Practice User"
git config --local user.email "practice@example.com"

printf '# Practice project\n' > README.md
printf 'Notes\n-----\nFirst note.\n' > notes.txt
printf 'TODO\n- learn git\n' > todo.txt
printf 'temporary debug output\n' > debug.log
printf 'PASSWORD=hunter2\n' > secret.env
printf 'binary-ish build output\n' > build/output.bin

echo "Created $hw"
echo "Next:  cd practice/hw2   then  git status   and do tasks 2.1-2.5."
