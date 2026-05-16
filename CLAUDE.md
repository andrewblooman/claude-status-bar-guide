# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a guide repo — its primary artifact is the README.md user guide explaining how to configure the Claude Code status bar, illustrated with screenshots in `assets/images/`. The only executable code is `statusline.sh`.

## statusline.sh

A self-contained Bash script that reads a JSON blob from stdin (piped by Claude Code) and prints a single colored status line. Key sections:

- **Model** — from `.model.display_name`
- **Directory** — basename derived from `.workspace.current_dir` (falls back to `.cwd`)
- **Git branch** — live `git symbolic-ref` + `git status --porcelain` for dirty indicator
- **Context bar** — 10-block progress bar from `.context_window.used_percentage`, color-coded green/yellow/red at 70%/90%
- **Cost** — `.cost.total_cost_usd` formatted as `$0.00`
- **Duration** — `.cost.total_duration_ms` converted to `Xm Ys`
- **Rate limits** — `.rate_limits.five_hour.used_percentage` and `.rate_limits.seven_day.used_percentage`, color-coded green/yellow/red at 50%/80%

To test the script locally, pipe a JSON payload matching the above schema:

```bash
echo '{"model":{"display_name":"Sonnet 4.6"},"workspace":{"current_dir":"/home/user/myproject"},"context_window":{"used_percentage":10},"cost":{"total_cost_usd":0.05,"total_duration_ms":90000},"rate_limits":{"five_hour":{"used_percentage":4},"seven_day":{"used_percentage":4}}}' | bash statusline.sh
```

## Adding new status bar fields

All fields are assembled into `LINE` at the bottom of `statusline.sh` using `${SEP}` as a delimiter. Add a new field by extracting data from `$input` with `jq`, formatting it into a `*_STR` variable, then appending it to `LINE`.
