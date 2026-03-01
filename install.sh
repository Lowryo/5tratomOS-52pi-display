#!/usr/bin/env bash

###############################################################################
# install.sh – Automated installer for 5tratomOS 52Pi display dashboard
#
# This script will:
#   1. Update system package lists and install required system packages.
#   2. Install Python packages required for the dashboard via pip.
#   3. Copy the dashboard script and systemd service into appropriate locations.
#   4. Enable I²C in /boot/config.txt (if not already enabled).
#   5. Reload systemd, enable the service, and start it immediately.
#
# Run this script on your Raspberry Pi (Debian/5tratomOS) to set up the display.
# Usage:
#   bash install.sh
#
# For a one‑liner installation directly from GitHub (after committing to your
# repository), you can use:
#   curl -fsSL https://raw.githubusercontent.com/Lowryo/5tratomOS-52pi-display/main/install.sh | bash
#
###############################################################################

set -euo pipefail

echo "[5tratom-display] Starting installation..."

# Ensure the script is run from the repository root, where dashboard.py resides.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

##########################################################################
# Step 1: Install system packages
##########################################################################
echo "[5tratom-display] Updating package lists and installing system dependencies..."
sudo apt-get update -y
sudo apt-get install -y \
  python3 \
  python3-pip \
  python3-dev \
  build-essential \
  libjpeg-dev \
  zlib1g-dev \
  libfreetype6-dev \
  i2c-tools \
  curl

##########################################################################
# Step 2: Install Python packages
##########################################################################
echo "[5tratom-display] Installing Python packages via pip..."
sudo pip3 install --no-cache-dir --break-system-packages \
  luma.oled \
  Pillow \
  psutil \
  netifaces

##########################################################################
# Step 3: Copy files into place
##########################################################################
TARGET_DIR="/opt/5tratom-display"
SERVICE_NAME="5tratom-display.service"

echo "[5tratom-display] Creating target directory $TARGET_DIR..."
sudo mkdir -p "$TARGET_DIR"

echo "[5tratom-display] Copying dashboard.py to $TARGET_DIR..."
sudo install -m 0755 "$SCRIPT_DIR/dashboard.py" "$TARGET_DIR/dashboard.py"

echo "[5tratom-display] Copying systemd service file..."
sudo install -m 0644 "$SCRIPT_DIR/$SERVICE_NAME" "/etc/systemd/system/$SERVICE_NAME"

##########################################################################
# Step 4: Enable I²C if necessary
##########################################################################
CONFIG="/boot/config.txt"
PARAM="dtparam=i2c_arm=on"

if ! grep -q "^$PARAM" "$CONFIG"; then
  echo "[5tratom-display] Enabling I²C in $CONFIG..."
  echo "$PARAM" | sudo tee -a "$CONFIG" >/dev/null
else
  echo "[5tratom-display] I²C already enabled in $CONFIG. Skipping."
fi

##########################################################################
# Step 5: Enable and start the service
##########################################################################
echo "[5tratom-display] Reloading systemd daemon and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

echo "[5tratom-display] Installation complete! The display should show system information shortly."