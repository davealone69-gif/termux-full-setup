# Termux Full Setup

**One-command complete Termux environment** for Android (development + optional AI gateway).

Works with Termux from **F-Droid** or **GitHub releases** (do **not** use the outdated Google Play version).

## Quick Start (Recommended)

1. Install Termux (F-Droid or GitHub).
2. Open Termux and run:

```bash
pkg update -y && pkg upgrade -y
pkg install curl -y
bash <(curl -fsSL https://raw.githubusercontent.com/davealone69-gif/termux-full-setup/main/setup.sh)
```

The script will:

- Update packages
- Enable storage access
- Install essential tools (git, openssh, nodejs, python, build tools, etc.)
- Configure Git identity (prompts you)
- Offer SSH key generation for GitHub
- Install GitHub CLI (`gh`) and help you authenticate
- Add useful aliases and a nice prompt
- Optionally install **OmniRoute** (self-hosted AI router with 290+ providers)
- Optionally set up Termux:Boot auto-start

## Manual Steps Overview

```bash
# 1. Update
pkg update && pkg upgrade -y

# 2. Storage access (important!)
termux-setup-storage

# 3. Core packages
pkg install -y git openssh curl wget nano vim python nodejs-lts \
  build-essential clang make pkg-config \
  gh termux-api

# 4. Configure Git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global init.defaultBranch main
git config --global credential.helper store

# 5. SSH key for GitHub (recommended)
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
# → Add this key at https://github.com/settings/keys

# 6. GitHub CLI auth
gh auth login
```

## Optional: OmniRoute (AI Gateway)

OmniRoute gives you one OpenAI-compatible endpoint (`http://localhost:20128/v1`) that can route across 290+ providers (many free).

```bash
# After the main setup
pkg install -y nodejs-lts python build-essential
npm install -g omniroute   # or: npx -y omniroute@latest
omniroute
```

Dashboard: `http://localhost:20128`  
API: `http://localhost:20128/v1`

For background + auto-start on boot (requires Termux:Boot):

```bash
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/omniroute.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
cd "$HOME"
nohup omniroute > "$HOME/omniroute.log" 2>&1 &
EOF
chmod +x ~/.termux/boot/omniroute.sh
```

## Useful Aliases (added by setup.sh)

| Alias | What it does |
|-------|--------------|
| `ll`  | `ls -la` |
| `gs`  | `git status` |
| `ga`  | `git add` |
| `gc`  | `git commit` |
| `gp`  | `git push` |
| `gl`  | `git log --oneline --graph` |
| `omni`| Start OmniRoute |

## Requirements

- Android 7+ (preferably 8+)
- Termux from F-Droid / GitHub (not Play Store)
- ~2–4 GB free storage for a full setup
- Internet connection

## Files in this repo

| File | Purpose |
|------|---------|
| `setup.sh` | Main interactive installer |
| `omniroute-termux.sh` | OmniRoute-specific helper |
| `aliases.sh` | Useful aliases (sourced by setup) |
| `README.md` | This file |

## Safety notes

- The script only installs packages from official Termux repositories + npm (for OmniRoute).
- It never asks for root.
- SSH keys stay on your device; you must manually add the public key to GitHub.

## License

MIT – free to use, modify, and share.

---

**Made for people who want a real Linux-like environment on Android.**
