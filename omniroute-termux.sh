#!/data/data/com.termux/files/usr/bin/bash
# OmniRoute helper for Termux
# Usage: bash omniroute-termux.sh

set -e

echo "=== OmniRoute on Termux ==="

# Prerequisites
pkg update -y
pkg install -y nodejs-lts python build-essential git

echo
echo "Choose install method:"
echo "  1) Global (npm install -g)"
echo "  2) One-shot (npx)"
read -p "Choice [1/2]: " choice

case "$choice" in
  2)
    echo "Starting with npx..."
    npx -y omniroute@latest
    ;;
  *)
    echo "Installing globally..."
    npm install -g omniroute || {
      echo "Global install failed. Falling back to npx."
      npx -y omniroute@latest
    }
    echo
    echo "Start with: omniroute"
    echo "Or in background: nohup omniroute > omniroute.log 2>&1 &"
    ;;
esac

echo
echo "Dashboard: http://localhost:20128"
echo "API base:  http://localhost:20128/v1"
echo
echo "For auto-start on boot (needs Termux:Boot):"
echo "  mkdir -p ~/.termux/boot"
echo "  # then create the boot script as shown in the main README"
