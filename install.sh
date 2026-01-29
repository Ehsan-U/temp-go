#!/bin/bash
set -e

# determine architecture
architecture=$(uname -m)
case $architecture in
  x86_64)  agent_filename="agent-amd64" ;;
  arm64|aarch64) agent_filename="agent-arm64" ;;
  *) echo "unsupported architecture: $architecture"; exit 1 ;;
esac
echo "architecture: $architecture"

# stop existing agent if running
magent stop 2>/dev/null || true

# download binary
echo "downloading agent"
url_base="https://raw.githubusercontent.com/Ehsan-U/temp-go/main"
curl -sLf -o "/usr/local/bin/magent" "$url_base/$agent_filename"
chmod +x "/usr/local/bin/magent"
echo "installed /usr/local/bin/magent"

echo ""
echo "  magent start --token=<MASTER_TOKEN>  (first run)"
echo "  magent stop"
echo "  magent status"
echo "  magent version"
