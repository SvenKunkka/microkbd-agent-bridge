#!/bin/sh
set -eu

echo "== USB identity =="
if command -v ioreg >/dev/null 2>&1; then
  ioreg -p IOUSB -l -w0 | grep -E 'Codex Micro@|idProduct.*33632|idVendor.*12346|USB Vendor Name.*Work Louder' || true
else
  echo "ioreg is unavailable; inspect the USB device manually."
fi

echo
echo "== Microbridge =="
if command -v microbridgectl >/dev/null 2>&1; then
  microbridgectl status
elif [ -x /Applications/Microbridge.app/Contents/MacOS/microbridgectl ]; then
  /Applications/Microbridge.app/Contents/MacOS/microbridgectl status
elif [ -x "$HOME/Applications/Microbridge.app/Contents/MacOS/microbridgectl" ]; then
  "$HOME/Applications/Microbridge.app/Contents/MacOS/microbridgectl" status
else
  echo "microbridgectl was not found. Install or launch Microbridge first."
  exit 1
fi
