# Setup general settings
alias vi="nvim"
alias vim="nvim"
alias k="kubectl"

setopt no_beep
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_cd
setopt hist_ignore_dups
setopt share_history
setopt inc_append_history

export HISTSIZE=100000
export SAVEHIST=100000

rm() { echo "rm is disabled. Use trash instead." >&2; return 1; }

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Setup zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# compinit runs after the plugins that add completions (zsh-completions) or call
# compdef (enhancd aliases cd to __enhancd::cd); zinit defers those compdef calls
# until zicdreplay, so without it `cd <TAB>` completes nothing.
zinit wait lucid light-mode for \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions \
    b4b4r07/enhancd \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting

# Setup other tools
eval "$(starship init zsh)"

eval "$(mise activate zsh)"

export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

export LIBRARY_PATH="$LIBRARY_PATH:$(brew --prefix)/lib"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"
export PATH="$HOME/.local/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# gws: run against a named Google account (one OAuth client, per-account config dir)
# New names are provisioned on first use; follow with `gwsa <name> auth login --scopes ...`.
gwsa() {
    local root="$HOME/.config/gws-accounts" dir="$HOME/.config/gws-accounts/$1"
    if [[ -z "$1" ]]; then
        echo "usage: gwsa <account> <gws args...>   (have: $(ls "$root" 2>/dev/null | grep -v '\.json$' | tr '\n' ' '))" >&2
        return 1
    fi
    if [[ ! -e "$dir/client_secret.json" ]]; then
        mkdir -p "$dir" && ln -sf ../client_secret.json "$dir/client_secret.json" || return 1
    fi
    shift
    GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$dir" gws "$@"
}
