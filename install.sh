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
timeout 3 magent stop 2>/dev/null || true
pkill -9 -f magent 2>/dev/null || true
sleep 1

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

# create systemd service for autostart
service_path="/etc/systemd/system/magent.service"
tmp_service="/tmp/magent.service.$$"

cat > "$tmp_service" << EOF
[Unit]
Description=Monitoring Agent
After=network.target

[Service]
Type=forking
User=$USER
PIDFile=$HOME/.local/magent/magent.pid
ExecStart=$install_dir/magent start
ExecStop=$install_dir/magent stop
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "installing systemd service (requires sudo)..."
sudo mv "$tmp_service" "$service_path"
sudo systemctl daemon-reload
sudo systemctl enable magent.service
echo "magent.service installed and enabled"

# add to PATH if not already there
if ! echo "$PATH" | grep -q "$install_dir"; then
  shell_rc="$HOME/.bashrc"
  if [ -f "$HOME/.zshrc" ]; then
    shell_rc="$HOME/.zshrc"
  fi
  echo "export PATH=\"$install_dir:\$PATH\"" >> "$shell_rc"
  export PATH="$install_dir:$PATH"
  echo "added $install_dir to PATH in $shell_rc"
fi
echo ""
echo "commands:"
echo "  magent start --token=<MASTER_TOKEN>  (first run, saves token)"
echo "  magent stop"
echo "  magent status"
echo "  magent version"
