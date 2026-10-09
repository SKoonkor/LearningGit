# Git & GitHub from Zero

A beginner-friendly lecture course on Git and GitHub, from "what is version control?" to pull requests, rebasing and recovering lost work. Each lecture is a PDF with diagrams, worked examples and homework that checks itself.

## Layout

| Folder | What is in it |
|---|---|
| `lectures/` | The lecture PDFs (`L00_...pdf`, `L01_...pdf`, ...). Sources are in `lectures/src/`. |
| `codeHints/Lxx/` | For each lecture: `setup_hwX.sh` builds a practice repository, `check_hwX.sh` prints PASS/FAIL for your work. |
| `solutions/Lxx/` | Worked solutions as a PDF. They are also at the end of each lecture, on a new page. |
| `practice/` | Created by the setup scripts. Your sandbox repositories live here (not tracked by Git). |

## How to use it

1. Read the lecture PDF in order, starting with `L00`.
2. Type every command yourself.
3. Do the homework: `bash codeHints/Lxx/setup_hwX.sh`, work in `practice/`, then `bash codeHints/Lxx/check_hwX.sh`.
4. Open the solutions only after the checker says PASS.

You need Git 2.28 or newer and `bash` (on Windows, use Git Bash).

## Rebuilding the PDFs

Needs a LaTeX installation with `latexmk`:

```
cd lectures/src/L00 && latexmk -pdf main.tex
```
