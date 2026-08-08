#!/data/data/com.termux/files/usr/bin/bash
# Termux Full Setup - Interactive installer
# https://github.com/davealone69-gif/termux-full-setup

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║     Termux Full Setup                    ║"
echo "║     Complete Android Terminal Env        ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ---------- helpers ----------
ask() {
  local prompt="$1"
  local default="${2:-y}"
  local reply
  read -p "$prompt [$default]: " reply
  reply=${reply:-$default}
  case "$reply" in
    [Yy]* ) return 0 ;;
    * ) return 1 ;;
  esac
}

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# ---------- 1. Update ----------
info "Updating package lists..."
pkg update -y
pkg upgrade -y

# ---------- 2. Storage ----------
if [ ! -d "$HOME/storage" ]; then
  info "Setting up storage access..."
  termux-setup-storage || warn "Could not run termux-setup-storage (permission may be needed)"
else
  info "Storage already configured."
fi

# ---------- 3. Core packages ----------
info "Installing core packages (this may take a few minutes)..."
pkg install -y \
  git openssh curl wget nano vim \
  python nodejs-lts \
  build-essential clang make pkg-config \
  gh termux-api \
  proot proot-distro \
  htop neofetch \
  zip unzip tar \
  which

# ---------- 4. Git identity ----------
echo
if ask "Configure Git user.name and user.email now?"; then
  read -p "Git user.name: " git_name
  read -p "Git user.email: " git_email
  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
  git config --global init.defaultBranch main
  git config --global credential.helper store
  git config --global core.editor nano
  info "Git configured."
else
  warn "Skipped Git identity. You can set it later with git config."
fi

# ---------- 5. SSH key ----------
echo
if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
  if ask "Generate a new SSH key for GitHub?"; then
    read -p "Email for SSH key comment: " ssh_email
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "${ssh_email:-termux@android}" -f "$HOME/.ssh/id_ed25519" -N ""
    info "SSH key generated."
    echo
    echo -e "${YELLOW}Public key (copy this to GitHub → Settings → SSH and GPG keys):${NC}"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo
    echo "Add it at: https://github.com/settings/keys"
  fi
else
  info "SSH key already exists."
  if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo -e "${YELLOW}Your public key:${NC}"
    cat "$HOME/.ssh/id_ed25519.pub"
  fi
fi

# ---------- 6. GitHub CLI auth ----------
echo
if command -v gh >/dev/null 2>&1; then
  if ask "Authenticate with GitHub CLI (gh auth login)?"; then
    gh auth login || warn "gh auth login failed or was cancelled."
  fi
fi

# ---------- 7. Aliases & shell config ----------
info "Adding useful aliases and prompt..."

cat > "$HOME/.termux_aliases" << 'ALIASES'
# Termux Full Setup aliases
alias ll='ls -la --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias ..='cd ..'
alias ...='cd ../..'
alias omni='omniroute'
alias update='pkg update && pkg upgrade -y'
ALIASES

# Source aliases from bashrc / zshrc
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$rc" ] || [ "$rc" = "$HOME/.bashrc" ]; then
    touch "$rc"
    if ! grep -q "termux_aliases" "$rc" 2>/dev/null; then
      echo "" >> "$rc"
      echo "# Termux Full Setup" >> "$rc"
      echo "[ -f \"\$HOME/.termux_aliases\" ] && source \"\$HOME/.termux_aliases\"" >> "$rc"
    fi
  fi
done

# Simple colored prompt if not already customized
if [ -f "$HOME/.bashrc" ] && ! grep -q "PS1=" "$HOME/.bashrc"; then
  echo 'export PS1="\[\e[32m\]\u@termux\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "' >> "$HOME/.bashrc"
fi

# ---------- 8. Optional OmniRoute ----------
echo
if ask "Install OmniRoute (self-hosted AI gateway with 290+ providers)?"; then
  info "Installing OmniRoute..."
  # Ensure build tools are present
  pkg install -y nodejs-lts python build-essential || true
  npm install -g omniroute || {
    warn "Global install failed (common on low-memory devices). Trying npx instead."
    echo "You can later run: npx -y omniroute@latest"
  }
  info "OmniRoute installed (or available via npx)."
  echo "Start it with: omniroute   or   npx omniroute"
  echo "Dashboard: http://localhost:20128"
fi

# ---------- 9. Optional boot script ----------
echo
if ask "Create Termux:Boot script for OmniRoute (requires Termux:Boot app)?"; then
  mkdir -p "$HOME/.termux/boot"
  cat > "$HOME/.termux/boot/omniroute.sh" << 'BOOT'
#!/data/data/com.termux/files/usr/bin/sh
cd "$HOME"
nohup omniroute > "$HOME/omniroute.log" 2>&1 &
BOOT
  chmod +x "$HOME/.termux/boot/omniroute.sh"
  info "Boot script created at ~/.termux/boot/omniroute.sh"
  warn "Install Termux:Boot from F-Droid for auto-start on device boot."
fi

# ---------- Done ----------
echo
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Setup complete!                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo
echo "Next steps:"
echo "  1. Restart Termux or run: source ~/.bashrc"
echo "  2. If you generated an SSH key, add it to GitHub."
echo "  3. Try: git --version && node --version && python --version"
echo "  4. Optional: omniroute   →  open http://localhost:20128"
echo
echo "Repo: https://github.com/davealone69-gif/termux-full-setup"
echo
