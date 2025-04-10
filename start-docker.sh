#!/bin/bash

if command -v ip > /dev/null; then
  # Linux
  if ip addr show eth0 | grep -q "inet "; then
    HOST_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
  elif ip addr show wlan0 | grep -q "inet "; then
    HOST_IP=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
  else
    HOST_IP=$(ip route get 1 | awk '{for(i=1;i<=NF;i++) if ($i == "src") print $(i+1)}')
  fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  # Try Ethernet first (en0 or en1), fallback to Wi-Fi
  if ipconfig getifaddr en0 > /dev/null 2>&1; then
    HOST_IP=$(ipconfig getifaddr en0)
  elif ipconfig getifaddr en1 > /dev/null 2>&1; then
    HOST_IP=$(ipconfig getifaddr en1)
  else
    HOST_IP="127.0.0.1"
  fi

else
  echo "Unable to determine local IP: unsupported OS"
  HOST_IP="127.0.0.1"
fi

export HOST_IP
echo "Local IP: $HOST_IP"

echo "starting docker..."
docker run -d --rm --name escpos_netprinter -p 515:515/tcp -p 80:80/tcp -p 9100:9100/tcp -e HOST_IP=$HOST_IP escpos-netprinter:2.0
