# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Initialize Starship prompt
eval "$(starship init bash)"

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
export PATH="$PATH:$HOME/.cache/lm-studio/bin"

# bun
export BUN_INSTALL="$HOME/Library/Application Support/reflex/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv bash)"
export PATH=${PATH}:/opt/homebrew/opt/python/libexec/bin

# -------------------------------------------------------
# for AFNI: auto-inserted by init_user_dotfiles.py

# add AFNI abin to PATH
export PATH=${PATH}:$HOME/abin

# set up tab completion for AFNI programs
if [ -f $HOME/.afni/help/all_progs.COMP.bash ]
then
   source $HOME/.afni/help/all_progs.COMP.bash
fi
# -------------------------------------------------------


eval "$(/opt/homebrew/bin/brew shellenv bash)"
export PATH=${PATH}:/opt/homebrew/opt/python/libexec/bin
export R_LIBS=$HOME/sw/R-4.3.1

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
