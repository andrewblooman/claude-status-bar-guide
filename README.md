# Claude Code Status Bar Guide

[![License](https://img.shields.io/github/license/andrewblooman/claude-status-bar-guide)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/andrewblooman/claude-status-bar-guide)](https://github.com/andrewblooman/claude-status-bar-guide/commits/main)
[![Stars](https://img.shields.io/github/stars/andrewblooman/claude-status-bar-guide)](https://github.com/andrewblooman/claude-status-bar-guide/stargazers)

How to add a custom status bar to Claude Code showing model, context, git status, cost, and rate limits.

---

## Option 1 — Automated setup

Run `/statusline` in Claude Code and describe what you want in plain English.

![Automated setup prompt](assets/images/automated_setup.png)

Example prompt used here:

```text
/statusline show model name, context percentage with a progress bar, git status, rate limits and session duration
```

Result:

![Status bar v1](assets/images/status_bar_v1.png)

---

## Option 2 — Manual setup

**Prerequisites:** `jq` must be installed (`brew install jq` / `apt install jq`). `git` is required for branch display but optional.

To get started, copy the [`statusline.sh`](statusline.sh) file to from this Repo and store it in your Claude home directory to and make it executable:

```bash
cp statusline.sh ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
```

Then add the following to `~/.claude/settings.json` to tell Claude Code to use it:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

This gives you a richer bar with color-coded context usage, rate limits, cost, and duration.

![Status bar v2](assets/images/status_bar_v2.png)

---

## Further reading

[Anthropic status line documentation](https://code.claude.com/docs/en/statusline)
