# Just source this file at the begining of your ~/.zshrc
# export MY_ZSH_CONFIG_FOLDER_PATH = "this_folder_path"

# Check if MY_ZSH_CONFIG_FOLDER_PATH is set
if [[ -z "$MY_ZSH_CONFIG_FOLDER_PATH" ]]; then
  echo "Error: MY_ZSH_CONFIG_FOLDER_PATH is not set."
  return 1
fi

# Enable persistent history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# Initialize completion
autoload -U compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'


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

export GOPATH=$HOME/gopath
export ANDROID_HOME="$HOME/Android/Sdk"
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$JAVA_HOME/bin:$PATH"
export LAUNCH_EDITOR="idea"

# Getting all the executable in ~/bin folder
#echo 'export PATH=~/bin:$PATH' >> ~/.bash_profile
export PATH=~/bin:$PATH
export PATH=~/gopath/bin:$PATH

# config folder
# syntax highlighting in the command
source $MY_ZSH_CONFIG_FOLDER_PATH/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
# vi mode in command line
source $MY_ZSH_CONFIG_FOLDER_PATH/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Fix fzf to work with vi-mode - must be in zvm_after_init hook
function zvm_after_init() {
  # get fzf at completion
  source $MY_ZSH_CONFIG_FOLDER_PATH/command-line-fzf.sh
  # key binding ctrl+r for fzf or alt-c
  source /usr/share/doc/fzf/examples/key-bindings.zsh

alias ls='ls --color=auto'
}

# todo: put this in the bluetooth-connection.sh
# list the bluetooth device in the ~/.bluetoot_devices file this way : <MAC-ADDRESSE>|device_name
BT_DEVICE_FILE="$HOME/.bluetooth_devices"
export BT_DEVICE_FILE

# Giving kubectl command completion 
source <(kubectl completion zsh)

# The most important aliases ever (the only thing I borrowed from OMZ)
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias lsa='ls -lah'

# my custom aliases
alias zig="/home/vkdev/zig/zig"
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
alias zt="zegemaType" 
alias update-discord="bash $HOME/my-zsh-configs/update-discord.sh"
alias idea="$HOME/local/share/JetBrains/Toolbox/apps/intellij-idea/bin/idea"
alias bt="$HOME/my-zsh-configs/go-cli/bluetooth-connection/bluetooth-connection"

alias switch-zsh='mv ~/.zshrc2 ~/.zshrc-tmp; mv ~/.zshrc ~/.zshrc2; mv ~/.zshrc-tmp ~/.zshrc'

alias hdr='mpv --vo=gpu-next --target-colorspace-hint --gpu-api=vulkan'

# Check if zig exist
if [ ! -d "$HOME/zig" ]; then
  echo "$HOME/zig does not exist."
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Display ASCII art matching terminal width on startup (new windows only)
if [[ -o interactive && -z "$ASCII_ART_SHOWN" ]]; then
  export ASCII_ART_SHOWN=1

  # Get terminal width
  term_width=$COLUMNS

  # Round DOWN to nearest multiple of 5
  art_width=$(( term_width / 5 * 5 ))

  # Only display if width is between 40 and 200
  if (( art_width >= 40 && art_width <= 200 )); then
    art_file="$MY_ZSH_CONFIG_FOLDER_PATH/img1/img1-${art_width}.txt"

    if [[ -f "$art_file" ]]; then
      cat "$art_file"
      read -k1 first_key
      clear

      # Only preserve keystroke if it's not Escape or whitespace
      if [[ "$first_key" != $'\e' && "$first_key" != " " && "$first_key" != $'\t' && "$first_key" != $'\n' ]]; then
        print -z "$first_key"
      fi
    fi
  fi
fi

