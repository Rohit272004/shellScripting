#!/bin/bash

CONFIG_FILE="$(dirname "$0")/monitor.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

mkdir -p "$LOG_DIR"

HEALTH_LOG="$LOG_DIR/health.log"
ALERT_LOG="$LOG_DIR/alert.log"
SECURITY_LOG="$LOG_DIR/security.log"

HOSTNAME=$(hostname)
TIME=$(date '+%Y-%m-%d %H:%M:%S')

CPU=$(top -bn1 | awk -F',' '/Cpu\(s\)/ {
    idle=$4
    gsub(/[^0-9.]/, "", idle)
    print 100-idle
}' | awk '{printf "%.0f", $1}')
[ -z "$CPU" ] && CPU=0

RAM=$(free | awk '/Mem:/ { printf "%.0f", ($3/$2)*100 }')
[ -z "$RAM" ] && RAM=0

DISK=$(df / | awk 'NR==2 { gsub("%","",$5); print $5 }')
[ -z "$DISK" ] && DISK=0

SSH_STATUS=$(systemctl is-active ssh 2>/dev/null || echo "inactive")
NGINX_STATUS=$(systemctl is-active nginx 2>/dev/null || echo "inactive")
DOCKER_STATUS=$(systemctl is-active docker 2>/dev/null || echo "inactive")

echo "$TIME hostname=$HOSTNAME cpu=${CPU}% ram=${RAM}% disk=${DISK}% ssh=$SSH_STATUS nginx=$NGINX_STATUS docker=$DOCKER_STATUS" >> "$HEALTH_LOG"

if [ "$CPU" -ge 80 ]; then
    echo "$TIME HIGH CPU: ${CPU}%" >> "$ALERT_LOG"
fi

if [ "$RAM" -ge 80 ]; then
    echo "$TIME HIGH RAM: ${RAM}%" >> "$ALERT_LOG"
fi

if [ "$DISK" -ge 80 ]; then
    echo "$TIME HIGH DISK: ${DISK}%" >> "$ALERT_LOG"
fi

if [ "$SSH_STATUS" != "active" ]; then
    echo "$TIME SSH service is $SSH_STATUS" >> "$ALERT_LOG"
fi

FAILED_SSH=$(journalctl _COMM=sshd --since "2 minutes ago" --no-pager 2>/dev/null | grep -c "Failed" || true)

if [ "$FAILED_SSH" -gt 0 ]; then
    echo "$TIME Failed SSH attempts in last 2 minutes: $FAILED_SSH" >> "$SECURITY_LOG"
fi

JSON_DATA=$(cat <<EOF
{
  "hostname": "$HOSTNAME",
  "cpu": $CPU,
  "ram": $RAM,
  "disk": $DISK,
  "services": {
    "ssh": "$SSH_STATUS",
    "nginx": "$NGINX_STATUS",
    "docker": "$DOCKER_STATUS"
  },
  "collectedAt": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
}
EOF
)

curl --silent --show-error   --max-time 10   -X POST "$SERVER_URL"   -H "Content-Type: application/json"   -H "Authorization: Bearer $AGENT_TOKEN"   -d "$JSON_DATA"

if [ "$?" -eq 0 ]; then
    echo "$TIME Data sent to backend successfully" >> "$HEALTH_LOG"
else
    echo "$TIME ERROR: Could not send data to backend" >> "$ALERT_LOG"
fi

exit 0
