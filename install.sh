#!/bin/bash
set -e

# determine architecture
architecture=$(uname -m)
case $architecture in
  x86_64)  agent_filename="agent-amd64" ;;
  arm64|aarch64) agent_filename="agent-arm64" ;;
  *) echo "error: unsupported architecture: $architecture"; exit 1 ;;
esac

# stop existing agent if running
magent stop 2>/dev/null || true

# install path
install_dir="$HOME/.local/bin"
mkdir -p "$install_dir"

# download binary
url_base="https://raw.githubusercontent.com/Ehsan-U/temp-go/main"
url="$url_base/$agent_filename"
echo "downloading $url"
if ! curl -sLf -o "$install_dir/magent" "$url"; then
  echo "error: failed to download agent from $url"
  exit 1
fi
chmod +x "$install_dir/magent"

echo ""
echo "installed magent $($install_dir/magent version) to $install_dir/magent"

# check if install_dir is in PATH
if ! echo "$PATH" | grep -q "$install_dir"; then
  echo ""
  echo "note: add $install_dir to your PATH:"
  echo "  export PATH=\"$install_dir:\$PATH\""
fi
echo ""
echo "commands:"
echo "  magent start --token=<MASTER_TOKEN>  (first run)"
echo "  magent stop"
echo "  magent status"
echo "  magent version"
