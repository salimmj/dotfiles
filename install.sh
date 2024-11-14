#!/usr/bin/env bash

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="dotfiles_install.log"

# Backup directory
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Function to log messages
log() {
  local message="$1"
  local level="${2:-INFO}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}

# Function to print error messages
error() {
  log "$1" "ERROR"
  echo -e "${RED}Error: $1${NC}" >&2
}

# Function to print success messages
success() {
  log "$1" "SUCCESS"
  echo -e "${GREEN}$1${NC}"
}

# Function to print warning messages
warning() {
  log "$1" "WARNING"
  echo -e "${YELLOW}Warning: $1${NC}"
}

# Function to print info messages
info() {
  log "$1" "INFO"
  echo -e "${BLUE}Info: $1${NC}"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to backup existing files
backup_file() {
  local file="$1"
  if [ -e "$file" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$file" "$BACKUP_DIR/$(basename "$file")"
    success "Backed up $file to $BACKUP_DIR/$(basename "$file")"
  fi
}

# Function to create symbolic links
create_symlink() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ]; then
    if [ -L "$dest" ]; then
      warning "Symlink already exists: $dest"
      rm "$dest"
    else
      backup_file "$dest"
    fi
  fi
  ln -sf "$src" "$dest"
  success "Created symlink: $dest -> $src"
}

git_config_filename=".gitconfig"

# Function to set up Git configuration
setup_git_config() {
  local repo_gitconfig_template="$(pwd)/$git_config_filename"
  local user_gitconfig="$HOME/.gitconfig"

  # Initialize variables with empty strings
  local user_name=""
  local user_email=""
  local user_signingkey=""

  if [ ! -f "$repo_gitconfig_template" ]; then
    error "$git_config_filename not found in the repository"
    return 1
  fi

  # Create or update .gitconfig.local
  if [ -f "$user_gitconfig" ]; then
    info "Existing .gitconfig.local found. Updating user information."
    local user_name=$(git config --global user.name)
    local user_email=$(git config --global user.email)
    local user_signingkey=$(git config --global user.signingkey)
  else
    info "Creating new .gitconfig"
    touch "$user_gitconfig"
  fi

    # Create or update .gitconfig in home directory
  cp "$repo_gitconfig_template" "$user_gitconfig"
  success "Added $git_config_filename to $user_gitconfig"

  # Prompt for user information if not already set
  if [ -z "$user_name" ]; then
    read -p "Enter your Git username: " user_name
  fi
  if [ -z "$user_email" ]; then
    read -p "Enter your Git email: " user_email
  fi
  if [ -z "$user_signingkey" ]; then
    read -p "Enter your Git signing key (optional): " user_signingkey
  fi

  # Prompt for user information if not already set
  if [ -z "${user_name:-}" ]; then
    read -p "Enter your Git username: " user_name
  fi
  if [ -z "${user_email:-}" ]; then
    read -p "Enter your Git email: " user_email
  fi
  if [ -z "${user_signingkey:-}" ]; then
    read -p "Enter your Git signing key (optional): " user_signingkey
  fi

  # Update .gitconfig.local with user information
  if [ -n "$user_name" ]; then
    git config --global user.name "$user_name"
  fi
  if [ -n "$user_email" ]; then
    git config --global user.email "$user_email"
  fi
  if [ -n "$user_signingkey" ]; then
    git config --global user.signingkey "$user_signingkey"
  fi

  success "Updated Git user information in $user_gitconfig"
}

# Function to install dotfiles
install_dotfiles() {
  log "Installing dotfiles..."
  local shared_dotfiles=(
    ".bashrc"
    ".bash_profile"
    ".profile"
    ".inputrc"
    ".vimrc"
    ".gitignore_global"
    ".gitattributes"
    ".editorconfig"
    ".aliases"
    ".functions"
    ".exports.shared"
    ".path.shared"
    ".scripts"          # Added scripts folder
  )
  local local_dotfiles=(
    ".path.local"
    ".exports.local"
    ".extra"
  )

  for file in "${shared_dotfiles[@]}"; do
    if [ -e "$file" ]; then
      create_symlink "$(pwd)/$file" "$HOME/$file"
    else
      warning "File or directory not found: $file"
    fi
  done

  for file in "${local_dotfiles[@]}"; do
    if [ ! -f "$HOME/$file" ]; then
      touch "$HOME/$file"
      success "Created empty $file in $HOME"
    else
      info "Local file $file already exists in $HOME"
    fi
  done

  # Handle .gitconfig as before
  if [ -f "$git_config_filename" ]; then
    setup_git_config
  else
    warning "$git_config_filename not found"
  fi

  # Handle starship.toml
  if [ -f "starship.toml" ]; then
    mkdir -p "$HOME/.config"
    create_symlink "$(pwd)/starship.toml" "$HOME/.config/starship.toml"
  else
    warning "starship.toml not found"
  fi
}

# Function to install packages on Debian-based systems
install_debian_packages() {
  log "Installing packages on Debian-based system..."
  sudo apt update
  sudo apt install -y git neovim tmux curl wget
}

# Function to install packages on Red Hat-based systems
install_redhat_packages() {
  log "Installing packages on Red Hat-based system..."
  sudo yum update
  sudo yum install -y git neovim tmux curl wget
}

# Function to install packages on macOS
install_macos_packages() {
  log "Installing packages on macOS..."

  # Check for and install Xcode Command Line Tools
  if ! xcode-select --print-path &> /dev/null; then
    log "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait until the installation is complete
    until xcode-select --print-path &> /dev/null; do
      sleep 5
    done
    log "Xcode Command Line Tools installed."
  fi

  # Install Homebrew if not already installed
  if ! command_exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" # Make sure Homebrew is sourced after installation
  fi

  # Update Homebrew
  brew update

  # List of formulae to install
  local formulae=(
    "git"
    "neovim"
    "tmux"
    "curl"
    "wget"
  )

  # List of casks to install
  local casks=(
    "spotify"
    # "brave-browser"
    "whatsapp"
    # "raycast"
    "cursor"
    "docker"
    "proton-pass"
    "protonvpn"
    "protonmail-bridge"
  )

  # Install formulae if not already installed
  for formula in "${formulae[@]}"; do
    if ! brew list "$formula" &>/dev/null; then
      log "Installing $formula..."
      brew install "$formula"
    else
      info "$formula is already installed"
    fi
  done

  # Function to check if an app is already installed
  is_app_installed() {
    local app_name="$1"
    # Check if the app exists in the /Applications directory or in brew list --cask
    [[ -d "/Applications/$app_name.app" ]] || brew list --cask "$app_name" &>/dev/null
  }

  # Install casks if not already installed
  for cask in "${casks[@]}"; do
    if ! is_app_installed "$cask"; then
      log "Installing $cask..."
      brew install --cask "$cask"
    else
      info "$cask is already installed"
    fi
  done
}

# Function to setup neovim
setup_neovim() {
  log "Setting up neovim..."
  mkdir -p ~/.config/nvim
  echo 'source ~/.vimrc' >~/.config/nvim/init.vim
}

# Function to install Starship prompt
install_starship() {
  if ! command_exists starship; then
    log "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  else
    log "Starship is already installed."
  fi
}

# Main installation function
main() {
  log "Starting dotfiles installation..."

  # Detect OS
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    log "Detected Linux system"
    if [ -f /etc/debian_version ]; then
      install_debian_packages
    elif [ -f /etc/redhat-release ]; then
      install_redhat_packages
    else
      error "Unsupported Linux distribution"
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    log "Detected macOS"
    install_macos_packages
  else
    error "Unsupported operating system: $OSTYPE"
    exit 1
  fi

  install_dotfiles
  install_starship
  setup_neovim

  # Change default shell to bashs if it's not already
  if [[ "$SHELL" != *"bash"* ]]; then
    log "Changing default shell to bash..."
    chsh -s "$(which bash)"
  fi

  success "Dotfiles installation completed successfully!"
  if [ -d "$BACKUP_DIR" ]; then
    info "Backup of old configurations created at: $BACKUP_DIR"
  fi
  log "Please restart your terminal or run 'source ~/.bashrc' to apply changes."
}

# Run the main function
main "$@"

