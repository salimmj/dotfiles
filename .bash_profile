# Source the .profile file
[ -f "$HOME/.profile" ] && source "$HOME/.profile"

# Source the .bashrc file
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/salim/.cache/lm-studio/bin"
