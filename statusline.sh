#!/usr/bin/env bash
# Claude Code status line — single output line

input=$(cat)

# --- Colors ---
BOLD_CYAN='\033[01;36m'
BOLD_GREEN='\033[01;32m'
BOLD_WHITE='\033[01;37m'
BOLD_YELLOW='\033[01;33m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
DIM='\033[2m'
RESET='\033[0m'
SEP="${DIM} | ${RESET}"

# --- Model ---
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
MODEL_STR="${BOLD_CYAN}[${MODEL}]${RESET}"

# --- Directory (basename only) ---
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
DISPLAY_CWD="${CWD/#$HOME/\~}"
BASENAME="${DISPLAY_CWD##*/}"
DIR_STR="${BOLD_WHITE}📁 ${BASENAME}${RESET}"

# --- Git branch ---
GIT_STR=""
if [ -n "$CWD" ] && git -C "$CWD" rev-parse --git-dir --no-optional-locks > /dev/null 2>&1; then
  BRANCH=$(git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$CWD" rev-parse --short HEAD 2>/dev/null)
  DIRTY=$(git -C "$CWD" status --porcelain --no-optional-locks 2>/dev/null)
  if [ -n "$DIRTY" ]; then
    GIT_STR="${BOLD_GREEN}🌿 ${BRANCH}${YELLOW}*${RESET}"
  else
    GIT_STR="${BOLD_GREEN}🌿 ${BRANCH}${RESET}"
  fi
fi

# --- Context bar (10 blocks, color-coded by usage) ---
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
PCT_INT=$(printf '%.0f' "$PCT")
FILLED=$(( PCT_INT / 10 ))
EMPTY=$(( 10 - FILLED ))
BAR=""
for i in $(seq 1 $FILLED 2>/dev/null); do BAR="${BAR}█"; done
EMPTY_BLOCKS=""
for i in $(seq 1 $EMPTY  2>/dev/null); do EMPTY_BLOCKS="${EMPTY_BLOCKS}░"; done
if   [ "$PCT_INT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT_INT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi
CTX_STR="${BAR_COLOR}${BAR}${DIM}${EMPTY_BLOCKS}${RESET} ${PCT_INT}%"

# --- Cost ---
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_FMT=$(printf '$%.2f' "$COST")
COST_STR="${BOLD_YELLOW}💰 ${COST_FMT}${RESET}"

# --- Duration ---
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
MINS=$(( DURATION_MS / 60000 ))
SECS=$(( (DURATION_MS % 60000) / 1000 ))
BOLD_MAGENTA='\033[01;35m'
DUR_STR="${BOLD_MAGENTA}🕖 ${MINS}m ${SECS}s${RESET}"

# --- Rate limits (color-coded by usage) ---
FIVE_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

_rate_color() {
  local pct=$1
  if   [ "$pct" -ge 80 ]; then printf '%b' "$RED"
  elif [ "$pct" -ge 50 ]; then printf '%b' "$YELLOW"
  else printf '%b' "$GREEN"; fi
}

RATE_STR=""
if [ -n "$FIVE_PCT" ]; then
  FP=$(printf '%.0f' "$FIVE_PCT")
  RATE_STR="$(_rate_color "$FP")Session limit: ${FP}%${RESET}"
fi
if [ -n "$WEEK_PCT" ]; then
  WP=$(printf '%.0f' "$WEEK_PCT")
  [ -n "$RATE_STR" ] && RATE_STR="${RATE_STR}${SEP}"
  RATE_STR="${RATE_STR}$(_rate_color "$WP")Weekly limit: ${WP}%${RESET}"
fi

# --- Assemble single line ---
LINE="${MODEL_STR}${SEP}${DIR_STR}"
[ -n "$GIT_STR" ] && LINE="${LINE}${SEP}${GIT_STR}"
LINE="${LINE}${SEP}${CTX_STR}${SEP}${COST_STR}${SEP}${DUR_STR}"
[ -n "$RATE_STR" ] && LINE="${LINE}${SEP}${DIM}${RATE_STR}${RESET}"

printf "%b" "${LINE}"
