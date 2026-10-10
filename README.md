# Git & GitHub from Zero

A beginner-friendly lecture course on Git and GitHub, from "what is version control?" to pull requests, rebasing and recovering lost work. Each lecture is a PDF with diagrams, worked examples and homework that checks itself. Eleven lectures, written to be done in order.

## The lectures

| # | PDF in `lectures/` | You will be able to... |
|---|---|---|
| 0 | `L00_roadmap.pdf` | explain what version control is, where Git came from, and Git vs GitHub |
| 1 | `L01_first_steps.pdf` | use the terminal, configure Git, run `git init` and `git status` |
| 2 | `L02_snapshots.pdf` | save versions with `add` and `commit`; use the three areas and `.gitignore` |
| 3 | `L03_history_undo.pdf` | read history (`log`, `show`, `diff`) and undo mistakes safely |
| 4 | `L04_branches.pdf` | work on ideas in parallel with branches |
| 5 | `L05_merging.pdf` | merge branches and resolve conflicts calmly |
| 6 | `L06_remotes_github.pdf` | set up GitHub and SSH; `clone`, `push`, `fetch`, `pull` |
| 7 | `L07_pull_requests.pdf` | open and review pull requests; fork and use `upstream` |
| 8 | `L08_rebase.pdf` | rebase, tidy history, cherry-pick, `--force-with-lease` |
| 9 | `L09_github_features.pdf` | use Issues, Actions (CI), branch protection, tags and releases |
| 10 | `L10_recovery_internals.pdf` | recover lost work (reflog), `reset`, `stash`, `bisect`, and see what is inside `.git` |

Parts: **A** (lectures 1-5) is Git on your own computer; **B** (6-7) is sharing and teamwork on GitHub; **C** (8-10) is advanced tools and recovery.

## Layout

| Folder | What is in it |
|---|---|
| `lectures/` | The lecture PDFs. LaTeX sources are in `lectures/src/` (one folder per lecture, shared style in `lectures/src/common/`). |
| `codeHints/Lxx/` | For each lecture: `setup_*.sh` builds a practice repository, `check_hwN.sh` prints PASS/FAIL for your work. `codeHints/common.sh` holds shared helpers. |
| `solutions/Lxx/` | Worked solutions as a PDF. They are also at the end of each lecture, always on a new page. |
| `practice/` | Created by the setup scripts. Your sandbox repositories live here. It is not tracked by Git. |

## How to use it

1. Read the lecture PDF in order, starting with `L00`.
2. Type every command yourself in a terminal.
3. Do the homework: run the lecture's setup script from the course folder, work inside `practice/`, then run the checker:

   ```
   bash codeHints/L02/setup_hw2.sh
   cd practice/hw2        # ...do the tasks...
   cd ../..
   bash codeHints/L02/check_hw2.sh
   ```

4. When everything says PASS, compare with the solutions (end of the lecture, or `solutions/Lxx/solutions.pdf`).

Every setup script can be rerun with `--reset` to start the exercise again. Never delete the course folder's own `.git`.

## What you need

- **Git 2.28 or newer** and **bash** (on Windows use *Git Bash*, which comes with Git for Windows; macOS and Linux already have bash).
- A free **GitHub account** and an **SSH key** from Lecture 6 on. Homework parts that really use GitHub (Lectures 6, 7, 9) are marked *optional* and are checked through GitHub's public interface; the offline parts need no internet.
- Lecture 7's Part B needs a **friend** (two GitHub accounts) for the pull-request exercises.
- To rebuild a PDF you need a LaTeX installation with `latexmk`:

  ```
  cd lectures/src/L04 && latexmk -pdf main.tex
  ```

## Working through it with friends

The exercises are designed so that you can do them together: compare answers after the checker passes, review each other's pull requests (Lecture 7), and try the recovery exercises (Lecture 10) on each other's practice repositories. If a checker disagrees with your result, read its FAIL message first; it names the task and what it expected.

## A note on the repository's own history

This repository was built lecture by lecture. Each lecture lives on its own branch (`lecture/L00-roadmap`, `lecture/L01-first-steps`, ...), stacked on the previous one, which is a good chance to practise pull requests and merging in the right order.
