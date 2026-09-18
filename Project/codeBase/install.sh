#!/bin/bash
set -e
echo "[*] Installing Full Project..."

# Bash part
sudo mkdir -p /var/log/server-monitor
sudo cp bash/config.conf bash/monitor.sh bash/security.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitor.sh /usr/local/bin/security.sh
sudo cp systemd/monitor.service systemd/monitor.timer systemd/security.service systemd/security.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now monitor.timer security.timer

# Backend part
cd backend
npm install
echo "[*] Backend deps installed. Run: node server.js or systemctl enable backend.service"

echo "[+] Done. Check:"
echo " systemctl list-timers | grep monitor"
echo " cat /var/log/server-monitor/health.log"
echo " cd backend && node server.js"
echo " cd frontend && npm install && npm start"
