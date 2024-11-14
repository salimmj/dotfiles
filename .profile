# Add ~/.local/bin to PATH if it exists
if [ -d "$HOME/.local/bin" ] ; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Set up Homebrew if it exists (works for both macOS and Linux)
if [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "/opt/homebrew/bin/brew" ]; then  # For Apple Silicon Macs
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Source shared configurations
for file in ~/.{aliases,functions,exports.shared,path.shared}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

# Source local configurations
for file in ~/.{path.local,exports.local,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

unset file

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/salim/.cache/lm-studio/bin"
