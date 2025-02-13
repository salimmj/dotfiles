# Only run for interactive shells:
[[ $- != *i* ]] && return


# Append history instead of overwriting
setopt APPEND_HISTORY

source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh


# Completion
autoload -U compinit && compinit

autoload -U history-substring-search
zle -N history-substring-search-up
zle -N history-substring-search-down

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


eval "$(starship init zsh)"


# Source Git aliases if the file exists
[ -f "$HOME/.git_aliases" ] && source "$HOME/.git_aliases"

# Add Cargo to PATH if it exists
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Source shared configurations
for file in ~/.{aliases,functions,exports.shared,path.shared}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

# Source local configurations
for file in ~/.{path.local,exports.local,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

unset file


. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/salim/.cache/lm-studio/bin"

# Added by bun
export BUN_INSTALL="$HOME/Library/Application Support/reflex/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Homebrew setup
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
export PATH="$PATH:/opt/homebrew/opt/python/libexec/bin"


# -------------------------------------------------------
# for AFNI: auto-inserted by init_user_dotfiles.py

# add AFNI abin to PATH
export PATH=${PATH}:/Users/salim/abin
# -------------------------------------------------------

export R_LIBS=/Users/salim/sw/R-4.3.1

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH=$PATH:/Users/salim/.spicetify

