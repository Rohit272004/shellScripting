# Linux Server Monitoring Dashboard — Steps 1 to 5

Architecture:
systemd timer -> Bash monitor agent -> Node.js API -> MongoDB
                                      -> Socket.IO -> React

Bash runs Linux commands, writes local logs, and sends structured metrics.
Node.js does not execute Linux commands.
MongoDB stores one metric every 2 minutes.
Socket.IO broadcasts each received metric to React.

## Backend
cd backend
npm install
cp .env.example .env
# Edit .env; AGENT_TOKEN must match agent/monitor.conf
npm run dev

Test:
curl http://localhost:5000/api/health
curl http://localhost:5000/api/history

## Agent
Make executable:
chmod +x agent/monitor.sh

After copying project to /opt:
sudo /opt/server-monitoring-project/agent/monitor.sh

Logs:
sudo tail -20 /var/log/server-monitor/health.log
sudo tail -20 /var/log/server-monitor/alert.log
sudo tail -20 /var/log/server-monitor/security.log

## systemd
sudo mkdir -p /opt/server-monitoring-project
sudo cp -r ./* /opt/server-monitoring-project/
sudo cp /opt/server-monitoring-project/agent/systemd/server-monitor.service /etc/systemd/system/
sudo cp /opt/server-monitoring-project/agent/systemd/server-monitor.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start server-monitor.service
sudo systemctl status server-monitor.service
sudo systemctl enable --now server-monitor.timer

Check:
systemctl status server-monitor.timer
systemctl list-timers server-monitor.timer
sudo journalctl -u server-monitor.service -n 20

## Frontend
cd frontend
npm install
npm run dev

Open the Vite URL, normally http://localhost:5173

Current scope:
Bash + AWK, local logs, curl, systemd service/timer, Express, MongoDB,
Socket.IO, React and Chart.js.

Not included yet:
multiple servers, advanced authentication, alerts/notifications,
backup/recovery, log rotation and production deployment.
