#!/usr/bin/env bash

###############################################################################
# install.sh – Automated installer for 5tratomOS 52Pi display dashboard
#
# Supports:
#   A) One-liner install (curl | bash)  -> downloads required files from GitHub
#   B) Local install (cloned repo)      -> uses local files
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/Lowryo/5tratomOS-52pi-display/main/install.sh | bash
###############################################################################

set -euo pipefail

APP_NAME="5tratom-display"
TARGET_DIR="/opt/${APP_NAME}"
SERVICE_NAME="5tratom-display.service"

# Repo raw base (for one-liner installs)
REPO_BASE="https://raw.githubusercontent.com/Lowryo/5tratomOS-52pi-display/main"

echo "[${APP_NAME}] Starting installation..."

##########################################################################
# Step 1: Install system packages
##########################################################################
echo "[${APP_NAME}] Updating package lists and installing system dependencies..."
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
echo "[${APP_NAME}] Installing Python packages via pip..."
sudo pip3 install --no-cache-dir --break-system-packages \
  luma.oled \
  Pillow \
  psutil \
  netifaces

##########################################################################
# Step 3: Put files into place
##########################################################################
echo "[${APP_NAME}] Creating target directory ${TARGET_DIR}..."
sudo mkdir -p "${TARGET_DIR}"

# Detect whether we have local files (cloned repo install)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install dashboard.py
if [[ -f "${SCRIPT_DIR}/dashboard.py" ]]; then
  echo "[${APP_NAME}] Using local dashboard.py"
  sudo install -m 0755 "${SCRIPT_DIR}/dashboard.py" "${TARGET_DIR}/dashboard.py"
else
  echo "[${APP_NAME}] Downloading dashboard.py from GitHub..."
  sudo curl -fsSL "${REPO_BASE}/dashboard.py" -o "${TARGET_DIR}/dashboard.py"
  sudo chmod +x "${TARGET_DIR}/dashboard.py"
fi

# Install service file
if [[ -f "${SCRIPT_DIR}/${SERVICE_NAME}" ]]; then
  echo "[${APP_NAME}] Using local ${SERVICE_NAME}"
  sudo install -m 0644 "${SCRIPT_DIR}/${SERVICE_NAME}" "/etc/systemd/system/${SERVICE_NAME}"
else
  echo "[${APP_NAME}] Downloading ${SERVICE_NAME} from GitHub..."
  sudo curl -fsSL "${REPO_BASE}/${SERVICE_NAME}" -o "/etc/systemd/system/${SERVICE_NAME}"
fi

##########################################################################
# Step 4: Enable I²C if necessary
##########################################################################
CONFIG="/boot/config.txt"
PARAM="dtparam=i2c_arm=on"
I2C_ENABLED_NOW=false

if [[ -f "${CONFIG}" ]]; then
  if ! grep -q "^${PARAM}$" "${CONFIG}"; then
    echo "[${APP_NAME}] Enabling I²C in ${CONFIG}..."
    echo "${PARAM}" | sudo tee -a "${CONFIG}" >/dev/null
    I2C_ENABLED_NOW=true
  else
    echo "[${APP_NAME}] I²C already enabled in ${CONFIG}. Skipping."
  fi
else
  echo "[${APP_NAME}] WARNING: ${CONFIG} not found. If I²C isn't enabled, enable it manually."
fi

##########################################################################
# Step 5: Enable and start the service
##########################################################################
echo "[${APP_NAME}] Reloading systemd daemon and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable "${SERVICE_NAME}"
sudo systemctl restart "${SERVICE_NAME}"

echo "[${APP_NAME}] Installation complete!"
echo "[${APP_NAME}] Check status with: sudo systemctl status ${SERVICE_NAME} --no-pager"

if [[ "${I2C_ENABLED_NOW}" == "true" ]]; then
  echo "[${APP_NAME}] I²C was just enabled. If the display does not respond, reboot now:"
  echo "  sudo reboot"
fi
