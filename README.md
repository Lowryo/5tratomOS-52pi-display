5tratomOS 52Pi Display

This repository contains setup scripts and documentation for integrating a 52Pi display with a Raspberry Pi 5 running 5tratomOS.

Purpose

The goal of this project is to provide an easy way to configure a small OLED/TFT display (such as the ones sold by 52Pi) to show useful system information and status indicators for your Raspberry Pi.
The scripts here will help you:

Enable the appropriate I²C/SPI interfaces.

Install required Python libraries (e.g. luma.oled, RPi.GPIO).

Render CPU temperature, network status, IP address, and other metrics on the screen.

Optionally run at boot via a systemd service.

Quick Start

You can set up the display in a single command once this repository is hosted on GitHub. Simply run the installer script directly from GitHub:

curl -fsSL https://raw.githubusercontent.com/Lowryo/5tratomOS-52pi-display/main/install.sh | bash

The installer will install all required system and Python packages, copy the necessary files, enable I²C, and register a systemd service to run the dashboard at boot. The display should start showing system information within a few seconds of finishing the installer.

If you prefer to run the installer manually, follow these steps:

Clone the repo (or download the files) onto your Raspberry Pi:

git clone https://github.com/Lowryo/5tratomOS-52pi-display.git
cd 5tratomOS-52pi-display

Run the installer script:

bash install.sh

The script will perform the same actions as the one‑liner above. You may run it with sudo but it elevates privileges internally as needed.

Files

dashboard.py – Python script to drive the OLED/TFT display and render system stats. It uses the luma.oled library to communicate with the display and shows CPU usage, memory usage, temperature, and IP address.

install.sh – Bash script that installs system dependencies, Python packages, enables I²C, copies files into /opt/5tratom-display, and sets up a systemd service.

5tratom-display.service – systemd unit file installed by install.sh to run the dashboard automatically at boot.

images/ – (Optional) directory for icons/assets if you decide to enhance the dashboard with graphics.

Contributing

This repository is in its early stages. If you have improvements, bug fixes, or additional display modules, feel free to open an issue or submit a pull request.

License

Released under the MIT License. See LICENSE
 for details.
