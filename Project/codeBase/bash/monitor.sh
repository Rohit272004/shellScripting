#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.conf"
mkdir -p $LOG_DIR

get_cpu(){ top -bn1 | grep "Cpu" | awk '{print $2}' | cut -d'.' -f1; }
get_ram(){ free | awk '/Mem/{printf "%.0f", $3/$2*100}'; }
get_disk(){ df / | awk 'NR==2{print $5}' | tr -d '%'; }

check_health(){
  local cpu=$(get_cpu)
  local ram=$(get_ram)
  local disk=$(get_disk)
  local time=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$time] CPU:${cpu}% RAM:${ram}% DISK:${disk}%" >> $HEALTH_LOG
  [ $cpu -gt $CPU_LIMIT ] && echo "[$time] ALERT High CPU $cpu%" >> $ALERT_LOG
  [ $ram -gt $RAM_LIMIT ] && echo "[$time] ALERT High RAM $ram%" >> $ALERT_LOG
  [ $disk -gt $DISK_LIMIT ] && echo "[$time] ALERT High DISK $disk%" >> $ALERT_LOG
}

check_services(){
  echo "===== $(date) SERVICE CHECK =====" >> $SECURITY_LOG
  for svc in $SERVICES; do
    status=$(systemctl is-active $svc 2>&1)
    echo "$svc : $status" >> $SECURITY_LOG
    if [ "$status" != "active" ]; then
      echo "[$(date)] ALERT $svc is $status" >> $ALERT_LOG
    fi
  done
}

check_inode(){
  echo "-- Inode Usage --" >> $SECURITY_LOG
  df -i / | tail -1 >> $SECURITY_LOG
  echo "-- Top CPU Processes --" >> $SECURITY_LOG
  ps aux --sort=-%cpu | head -6 >> $SECURITY_LOG
}

check_health
check_services
check_inode
