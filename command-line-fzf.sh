# Get the directory where this script is located
SCRIPT_DIR="${${(%):-%x}:A:h}"

# Define the fzf-tab plugin directory (in this config folder)
FZF_TAB_DIR="${SCRIPT_DIR}/fzf-tab"
FZF_COMPLETION_DIR="${SCRIPT_DIR}/fzf-zsh-completions"

# Check if fzf-tab is installed, if not clone it
if [[ ! -d "$FZF_TAB_DIR" ]]; then
    echo "fzf-tab plugin not found. Installing..."
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"

    # Check if clone was successful
    if [[ $? -eq 0 ]]; then
        echo "fzf-tab plugin installed successfully!"
    else
        echo "Error: Failed to install fzf-tab plugin"
        return 1
    fi
fi


# Source the fzf-tab plugin
source "$FZF_TAB_DIR/fzf-tab.plugin.zsh"

# Bind arrow down to trigger completion
bindkey '^[[B' fzf-tab-complete

# Configure fzf-tab to show colors
#zstyle ':fzf-tab:*' fzf-flags --color=fg:7,bg:-1,hl:4,fg+:7,bg+:0,hl+:12,info:6,prompt:4,pointer:12,marker:2,spinner:6,header:4
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -f $realpath ]] && cat $realpath 2>/dev/null || ls --color=always $realpath 2>/dev/null'

# Fuzzy-select a host from ~/.ssh/config and connect to it
sshf() {
    local host
    if [[ ! -f ~/.ssh/config ]]; then
        echo "No SSH config found at ~/.ssh/config"
        echo "Create it with:  touch ~/.ssh/config && chmod 600 ~/.ssh/config"
        echo "Then add one block per host, e.g.:"
        echo ""
        echo "  Host <device-nickname>"
        echo "    HostName <remote-IP>"
        echo "    User <remote-user>"
        echo ""
        echo "After that, 'ssh mac' and sshf will work."
        return 1
    fi
    host=$(awk '$1 ~ /^[Hh]ost$/ {for (i = 2; i <= NF; i++) if ($i !~ /[*?!]/) print $i}' ~/.ssh/config 2>/dev/null | sort -u |
        fzf --prompt='ssh > ' --height=~30% --reverse \
            --preview 'ssh -G {} 2>/dev/null | grep -E "^(user|hostname|port) "' \
            --preview-window=down:3:wrap) || return
    ssh "$host"
}

# Set up fzf key bindings and fuzzy completion
if [[ -z "$FZF_KEY_BINDINGS_PATH" ]]; then
  echo "Warning: FZF_KEY_BINDINGS_PATH is not set. Skipping fzf key bindings."
  echo "Please add: export FZF_KEY_BINDINGS_PATH=\"/path/to/key-bindings.zsh\" in your ~/.zshrc"
elif [[ ! -f "$FZF_KEY_BINDINGS_PATH" ]]; then
  echo "Warning: FZF_KEY_BINDINGS_PATH points to a non-existent file: $FZF_KEY_BINDINGS_PATH"
else
  source "$FZF_KEY_BINDINGS_PATH"
fi

