#!/usr/bin/env python3

"""
dashboard.py – OLED/TFT display dashboard for 5tratomOS on Raspberry Pi

This script drives a small OLED/TFT display (such as the 52Pi 1.3" OLED) via I²C
using the `luma.oled` library. It renders basic system information on the
screen, including CPU usage, memory usage, temperature, and IP address.  If
your display uses a different driver (e.g. SSD1306 vs SH1106), adjust the
`device = ...` line accordingly.

Prerequisites:
  - Enable I²C on your Raspberry Pi (`raspi-config` → Interface Options → I2C)
  - Install Python dependencies via `pip3 install luma.oled Pillow psutil netifaces`
  - Connect the display to the Pi's I2C pins (SDA, SCL) and power pins (5V/GND).

The script continuously updates the display every 2 seconds. You can stop it
with Ctrl‑C.
"""

import os
import time
import subprocess

import psutil
import netifaces
from PIL import Image, ImageDraw, ImageFont

from luma.core.interface.serial import i2c
from luma.oled.device import sh1106  # Change to ssd1306 if needed


def get_ip_address() -> str:
    """Return the first non-loopback IPv4 address or 'No IP'."""
    for iface in netifaces.interfaces():
        if iface == "lo":
            continue
        addrs = netifaces.ifaddresses(iface)
        ipv4_addrs = addrs.get(netifaces.AF_INET, [])
        for addr in ipv4_addrs:
            ip = addr.get("addr")
            if ip:
                return ip
    return "No IP"


def get_cpu_temp() -> str:
    """Return the CPU temperature as a string with °C or 'N/A' if unavailable."""
    # Many devices expose temperature in this path; adjust if different
    thermal_path = "/sys/class/thermal/thermal_zone0/temp"
    try:
        with open(thermal_path, "r", encoding="utf-8") as f:
            temp_str = f.read().strip()
            temp_c = float(temp_str) / 1000.0
            return f"{temp_c:.1f}°C"
    except Exception:
        return "N/A"


def main() -> None:
    """Initialize the display and start the update loop."""
    # Create I2C interface. The address 0x3C is typical for many small OLEDs.
    serial = i2c(port=1, address=0x3C)
    # Instantiate device: SH1106 is common for 1.3" 128x64 OLEDs.
    device = sh1106(serial, rotate=0)

    # Use a basic built‑in font. You can supply a TTF via ImageFont.truetype.
    font = ImageFont.load_default()

    while True:
        # Create a blank image for drawing.
        image = Image.new("1", (device.width, device.height))
        draw = ImageDraw.Draw(image)

        # Collect metrics
        cpu_percent = psutil.cpu_percent()
        mem_percent = psutil.virtual_memory().percent
        temp = get_cpu_temp()
        ip = get_ip_address()

        # Compose text lines
        line1 = f"CPU: {cpu_percent:.0f}%  MEM: {mem_percent:.0f}%"
        line2 = f"TEMP: {temp}"
        line3 = f"IP: {ip}"

        # Draw the text
        draw.text((0, 0), line1, font=font, fill=255)
        draw.text((0, 10), line2, font=font, fill=255)
        draw.text((0, 20), line3, font=font, fill=255)

        # Display the image
        device.display(image)

        # Wait before next update
        time.sleep(2)


if __name__ == "__main__":
    main()