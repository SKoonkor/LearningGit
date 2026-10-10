#!/usr/bin/env bash
# Setup for Homework 9 part A. Run from the course folder:  bash codeHints/L09/setup_hw9.sh
# Creates practice/hw9_server.git (plays the role of GitHub) with a tiny project whose
# test fails because of a typo. --reset rebuilds it.
root="$(cd "$(dirname "$0")/../.." && pwd)"
server="$root/practice/hw9_server.git"

if [ -e "$server" ] && [ "$1" != "--reset" ]; then
  echo "practice/hw9_server.git already exists. To start over run (from the course folder):"
  echo "  bash codeHints/L09/setup_hw9.sh --reset"
  exit 1
fi
rm -rf "$server" "$root/practice/hw9" "$root/practice/hw9_answers.txt" "$root/practice/.hw9_ids"
mkdir -p "$root/practice"
git init -q --bare -b main "$server" || { echo "git init failed (need Git 2.28 or newer)"; exit 1; }

seed="$(mktemp -d "${TMPDIR:-/tmp}/hw9seed.XXXXXX")"
trap 'cd "$root"; rm -rf "$seed"' EXIT
cd "$seed" || exit 1
git init -q -b main
git config user.name "Maintainer"
git config user.email "maintainer@example.com"
git config core.autocrlf false
git config commit.gpgsign false
git remote add origin "$server"

commit() {  # commit "message" "date"
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$1"
}

printf '# Greeter\nA tiny project used to practise GitHub features.\n' > README.md
git add README.md && commit "Add README" "2025-01-06T09:00:00+0000"
c1="$(git rev-parse HEAD)"

printf '#!/usr/bin/env bash\necho "Helo, world"\n' > greet.sh
cat > test.sh <<'TEST'
#!/usr/bin/env bash
# A tiny test: greet.sh must print exactly "Hello, world".
out="$(bash greet.sh)"
if [ "$out" = "Hello, world" ]; then
  echo "PASS"
else
  echo "FAIL: got '$out'"
  exit 1
fi
TEST
git add greet.sh test.sh && commit "Add greeter and its test" "2025-01-07T09:00:00+0000"
c2="$(git rev-parse HEAD)"
git push -q origin main

printf '%s\n%s\n' "$c1" "$c2" > "$root/practice/.hw9_ids"

echo "Created $server"
echo "A tiny project with a failing test. Next, from the practice/ folder:  git clone hw9_server.git hw9"
echo "Then do tasks 9.1-9.8."
