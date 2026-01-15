export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

[ "$TERM" = "xterm-ghostty" ] && export TERM=xterm-256color
. "$HOME/.cargo/env"

export ZK_NOTEBOOK_DIR="$HOME/notebook"
# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"


export PATH="$HOME/.local/bin:$PATH"
