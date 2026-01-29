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

# download binary
url_base="https://raw.githubusercontent.com/Ehsan-U/temp-go/main"
url="$url_base/$agent_filename"
echo "downloading $url"
if ! curl -sLf -o "/usr/local/bin/magent" "$url"; then
  echo "error: failed to download agent from $url"
  exit 1
fi
chmod +x "/usr/local/bin/magent"

echo ""
echo "installed magent $(magent version) to /usr/local/bin/magent"
echo ""
echo "commands:"
echo "  magent start --token=<MASTER_TOKEN>  (first run)"
echo "  magent stop"
echo "  magent status"
echo "  magent version"
