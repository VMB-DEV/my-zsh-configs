#!/usr/bin/env bash
# Claude Code status line — two lines, mirrors Starship prompt style

input=$(cat)

# Log input once for inspection
[ ! -f /tmp/.claude_sl_input.json ] && echo "$input" > /tmp/.claude_sl_input.json

cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~
home_dir="$HOME"
display_dir="${cwd/#$home_dir/\~}"

# Git branch and status (skip optional locks to avoid hangs)
git_branch=""
git_status_flags=""
if git_out=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null); then
  git_branch="$git_out"
  # Collect status indicators
  git_flags=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  if [ -n "$git_flags" ]; then
    git_status_flags="*"
  fi
  ahead=$(git -C "$cwd" --no-optional-locks rev-list @{u}..HEAD --count 2>/dev/null)
  behind=$(git -C "$cwd" --no-optional-locks rev-list HEAD..@{u} --count 2>/dev/null)
  [ "${ahead:-0}" -gt 0 ] 2>/dev/null && git_status_flags="${git_status_flags}⇡${ahead}"
  [ "${behind:-0}" -gt 0 ] 2>/dev/null && git_status_flags="${git_status_flags}⇣${behind}"
fi

# Return ANSI color prefix based on percentage thresholds
pct_color() {
  local pct
  pct=$(printf "%.0f" "$1")
  if [ "$pct" -ge 90 ]; then
    printf '\033[31m'   # red
  elif [ "$pct" -ge 80 ]; then
    printf '\033[38;5;208m'   # orange
  elif [ "$pct" -ge 70 ]; then
    printf '\033[33m'   # yellow
  else
    printf '\033[90m'   # gray
  fi
}
RESET=$'\033[0m'
DIM=$'\033[2m'
BOLD_YELLOW=$'\033[1;33m'
GREEN=$'\033[32m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
RED=$'\033[31m'
PINK=$'\033[95m'
ORANGE=$'\033[38;5;208m'

# Build the status line: two lines, joined with " | "
line1=()
line2=()

# Line 1: user@host | dir | branch | model effort
line1+=("${BOLD_YELLOW}${USER:-$(id -un)}@$(hostname -s)${RESET}")
line1+=("${BLUE}${display_dir}${RESET}")

if [ -n "$git_branch" ]; then
  git_part="⎇  ${git_branch}"
  git_color="$GREEN"
  if [ -n "$git_status_flags" ]; then
    git_part="${git_part} [${git_status_flags}]"
    git_color="$MAGENTA"
  fi
  line1+=("${git_color}${git_part}${RESET}")
fi

model_part="${RED}${model}${RESET}"
[ -n "$effort" ] && model_part="${model_part} ${PINK}${effort}${RESET}"
line1+=("$model_part")

# Line 2: mode | hour | ctx | quota 5h | quota 7d
# Vim mode (built-in indicator hidden via hideVimModeIndicator)
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    INSERT) vim_color="$ORANGE" ;;
    VISUAL*) vim_color="$MAGENTA" ;;
    *) vim_color="$BLUE" ;;
  esac
  GRAY=$'\033[90m'
  line2+=("${GRAY}----${RESET} ${vim_color}${vim_mode}${RESET} ${GRAY}----${RESET}")
fi

line2+=("${DIM}$(date +%H:%M)${RESET}")

if [ -n "$used_pct" ]; then
  printf_pct=$(printf "%.0f" "$used_pct")
  line2+=("$(pct_color "$used_pct")ctx:${printf_pct}%${RESET}")
fi

five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

if [ -n "$five_hour_pct" ]; then
  reset_str=""
  if [ -n "$five_hour_reset" ]; then
    reset_str=" ($(date -d "@${five_hour_reset}" +%H:%M))"
  fi
  five_hour_pct_fmt=$(printf "%.0f" "$five_hour_pct")
  line2+=("$(pct_color "$five_hour_pct")5h:${five_hour_pct_fmt}%${reset_str}${RESET}")
fi
if [ -n "$seven_day_pct" ]; then
  seven_day_pct_fmt=$(printf "%.0f" "$seven_day_pct")
  line2+=("$(pct_color "$seven_day_pct")7d:${seven_day_pct_fmt}%${RESET}")
fi

sep="${DIM} | ${RESET}"
join_parts() {
  local out=""
  for part in "$@"; do
    out="${out:+${out}${sep}}${part}"
  done
  printf "%s" "$out"
}

printf "%s\n%s" "$(join_parts "${line1[@]}")" "$(join_parts "${line2[@]}")"
