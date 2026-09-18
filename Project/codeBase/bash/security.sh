#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.conf"
mkdir -p $LOG_DIR
TIME=$(date '+%Y-%m-%d %H:%M:%S')

check_logins(){
  echo "===== $TIME LOGIN CHECK =====" >> $SECURITY_LOG
  who >> $SECURITY_LOG
  last -n 5 >> $SECURITY_LOG
  lastb -n 5 >> $SECURITY_LOG 2>&1
}

check_ssh(){
  echo "-- SSH Last 1 Hour --" >> $SECURITY_LOG
  journalctl _COMM=sshd --since "1 hour ago" | grep -E "Accepted|Failed" | tail -10 >> $SECURITY_LOG 2>&1
}

# NEW 1 - SUDO MONITORING
check_sudo(){
  echo "-- SUDO Usage Last 1 Hour --" >> $SECURITY_LOG
  journalctl --since "1 hour ago" | grep sudo | tail -10 >> $SECURITY_LOG 2>&1
  cat /var/log/auth.log 2>/dev/null | grep sudo | tail -10 >> $SECURITY_LOG
}

# NEW 2 - NETWORK CONNECTIONS
check_network(){
  echo "-- Open Ports --" >> $SECURITY_LOG
  ss -tuln | head -15 >> $SECURITY_LOG
  echo "-- Established Connections --" >> $SECURITY_LOG
  ss -tunap | grep ESTAB | head -10 >> $SECURITY_LOG 2>&1
}

# NEW 3 - BRUTEFORCE DETECTION
check_bruteforce(){
  echo "-- Bruteforce Check - Failed SSH per IP --" >> $SECURITY_LOG
  journalctl _COMM=sshd --since "1 hour ago" | grep Failed | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -5 >> $SECURITY_LOG 2>&1
  if [ $(journalctl _COMM=sshd --since "1 hour ago" | grep -c Failed) -gt 10 ]; then
    echo "[$TIME] ALERT Possible bruteforce attack" >> $ALERT_LOG
  fi
}

# NEW 4 - DOCKER MONITORING
check_docker(){
  echo "-- Docker Status --" >> $SECURITY_LOG
  docker ps -a 2>&1 | head -10 >> $SECURITY_LOG || echo "No docker" >> $SECURITY_LOG
}

check_usb(){
  echo "-- USB --" >> $SECURITY_LOG
  lsusb >> $SECURITY_LOG
  dmesg | grep -i usb | tail -5 >> $SECURITY_LOG
}

check_fileshare(){
  echo "-- File Share --" >> $SECURITY_LOG
  smbstatus -b 2>&1 | head -5 >> $SECURITY_LOG || echo "No Samba" >> $SECURITY_LOG
  cat /proc/mounts | grep nfs >> $SECURITY_LOG || echo "No NFS" >> $SECURITY_LOG
  echo "" >> $SECURITY_LOG
}

# MAIN - Call all
check_logins
check_ssh
check_sudo
check_network
check_bruteforce
check_docker
check_usb
check_fileshare
