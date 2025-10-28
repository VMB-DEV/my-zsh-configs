echo 'my zshrc'
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
alias ls='ls --color=auto'
alias lsa='ls -lah'

# Set up fzf key bindings and fuzzy completion
# source <(fzf --zsh)

# Set up zoxide to move between folders efficiently
eval "$(zoxide init zsh)"

# Set up the Starship prompt
# for a nerdfont
#mkdir -p ~/.local/share/fonts
#cd ~/.local/share/fonts
#wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
#unzip JetBrainsMono.zip
#rm JetBrainsMono.zip
#fc-cache -fv

eval "$(starship init zsh)"


# my custom aliases
alias switch-zsh='mv ~/.zshrc2 ~/.zshrc-tmp; mv ~/.zshrc ~/.zshrc2; mv ~/.zshrc-tmp ~/.zshrc'
alias zig="/home/vkdev/Downloads/zig-x86_64-linux-0.16.0-dev.233+a0ec4e270/zig"
alias switch-zsh='mv ~/.zshrc2 ~/.zshrc-tmp; mv ~/.zshrc ~/.zshrc2; mv ~/.zshrc-tmp ~/.zshrc'

# config folder
source /home/vkdev/my-zsh-configs/command-line-fzf.sh
# key binding ctrl+r for fzf or alt-c
source /usr/share/doc/fzf/examples/key-bindings.zsh

source /home/vkdev/my-zsh-configs/bluetooth-connection.sh
alias copad="btconnect D4:57:63:5D:62:EE"
alias dicopad="btdisconnect D4:57:63:5D:62:EE"

