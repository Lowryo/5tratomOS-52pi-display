# 5tratomOS 52Pi Display (Raspberry Pi 5)

This project lets you show live system information on a small 52Pi OLED screen connected to your Raspberry Pi running 5tratomOS.

It displays:

- CPU usage
- Memory usage
- CPU temperature
- IP address

You only need to run **one command**.

---

# ✅ BEFORE YOU START

Make sure:

- You are on your Raspberry Pi
- You are connected to the internet
- Your 52Pi OLED screen is wired correctly
  - SDA → SDA
  - SCL → SCL
  - 5V → 5V
  - GND → GND

If you're not sure, check your wiring first.

---

# 🚀 INSTALL (ONE COMMAND)

Open Terminal on your Raspberry Pi and paste this:

```bash
curl -fsSL https://raw.githubusercontent.com/Lowryo/5tratomOS-52pi-display/main/install.sh | bash
