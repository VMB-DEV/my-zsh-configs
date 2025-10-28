# Enable persistent history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# Initialize completion
autoload -U compinit; compinit

# Move to directories without cd
setopt autocd

# The most important aliases ever (the only thing I borrowed from OMZ)
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls -G'
alias lsa='ls -lah'

# Set up fzf key bindings and fuzzy completion
# source <(fzf --zsh)

# Set up zoxide to move between folders efficiently
eval "$(zoxide init zsh)"

# Set up the Starship prompt
eval "$(starship init zsh)"


# my custom aliases
alias switch-zsh='mv ~/.zshrc2 ~/.zshrc-tmp; mv ~/.zshrc ~/.zshrc2; mv ~/.zshrc-tmp ~/.zshrc'
