# Actually initializes the completion system, which enables tab completion in zsh
autoload -U compinit; compinit

# Get the directory where this script is located
SCRIPT_DIR="${${(%):-%x}:A:h}"

# Define the fzf-tab plugin directory (in this config folder)
FZF_TAB_DIR="${SCRIPT_DIR}/fzf-tab"

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
