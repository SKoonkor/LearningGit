#!/usr/bin/env bash
# Setup for Homework 1. Run from the course folder:  bash codeHints/L01/setup_hw1.sh
# Homework 1 is about creating a repository yourself, so this script only
# prepares the practice/ folder. It does NOT build the repository for you.
root="$(cd "$(dirname "$0")/../.." && pwd)"
mkdir -p "$root/practice"
echo "Ready. Your sandbox folder is: $root/practice"
echo "Now do tasks 1.1-1.6 from the lecture."
echo "When you are done, run:  bash codeHints/L01/check_hw1.sh"
