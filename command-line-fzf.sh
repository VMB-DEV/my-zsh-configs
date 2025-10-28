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

# Set up fzf key bindings and fuzzy completion (for fzf < 0.48.0)
source /usr/share/doc/fzf/examples/key-bindings.zsh

