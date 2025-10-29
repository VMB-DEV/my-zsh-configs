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

# Set up fzf key bindings and fuzzy completion
# source <(fzf --zsh)

# Set up zoxide to move between folders efficiently
#eval "$(zoxide init zsh)"

# Set up the Starship prompt
# for a nerdfont
#mkdir -p ~/.local/share/fonts
#cd ~/.local/share/fonts
#wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
#unzip JetBrainsMono.zip
#rm JetBrainsMono.zip
#fc-cache -fv

eval "$(starship init zsh)"

# Set up LS_COLORS for file type coloring
eval "$(dircolors -b)"

# Configure fzf colors
#export FZF_DEFAULT_OPTS="
#  --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
#  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
#  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
#  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
#"


# config folder
# vi mode in command line
source /home/vkdev/my-zsh-configs/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Fix fzf to work with vi-mode - must be in zvm_after_init hook
function zvm_after_init() {
  # get fzf at completion
  source /home/vkdev/my-zsh-configs/command-line-fzf.sh
  # key binding ctrl+r for fzf or alt-c
  source /usr/share/doc/fzf/examples/key-bindings.zsh

alias ls='ls --color=auto'
}

source /home/vkdev/my-zsh-configs/bluetooth-connection.sh
alias copad="btconnect D4:57:63:5D:62:EE"
alias dicopad="btdisconnect D4:57:63:5D:62:EE"

# The most important aliases ever (the only thing I borrowed from OMZ)
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias lsa='ls -lah'

# my custom aliases
alias zig="/home/vkdev/Downloads/zig-x86_64-linux-0.16.0-dev.233+a0ec4e270/zig"
alias intellij="~/.local/share/JetBrains/Toolbox/apps/intellij-idea-ultimate/bin/idea"
alias cl="clear" 
alias nr="npm run" 
alias k="kubectl" 
alias kctx="kubectx" 
alias kns="kubens" 
alias klocal="cp ~/.kube/config-local ~/.kube/config" 
alias kremote="cp ~/.kube/config-remote ~/.kube/config" 
alias kaf="kubectl apply -f" 
alias kak="kubectl apply -k" 
alias kdl="kubectl delete" 

alias switch-zsh='mv ~/.zshrc2 ~/.zshrc-tmp; mv ~/.zshrc ~/.zshrc2; mv ~/.zshrc-tmp ~/.zshrc'


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

