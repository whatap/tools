#!/usr/bin/env bash
set -e

ACTION=$1

# 기준 디렉토리 자동 추론
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
INSTALL_DIR="${2:-$(dirname "$SCRIPT_DIR")}"

CONFIG_DIR="$INSTALL_DIR/config"
BINARY="$INSTALL_DIR/bin/mq_prometheus"
RUN_DIR="/var/run/whatap_mq"
LOG_DIR="/var/log/whatap_mq"

# MQ 환경 설정
export MQ_INSTALLATION_PATH="$INSTALL_DIR/mqm"
export LD_LIBRARY_PATH="$MQ_INSTALLATION_PATH/lib64:$LD_LIBRARY_PATH"

mkdir -p "$RUN_DIR" "$LOG_DIR"

stop_all() {
  echo "[*] Stopping all exporters..."
  for pidfile in "$RUN_DIR"/*.pid; do
    [[ -e "$pidfile" ]] || continue
    pid=$(<"$pidfile")
    if ps -p "$pid" > /dev/null 2>&1; then
      echo " - Killing PID $pid"
      kill "$pid" 2>/dev/null || true
    fi
    rm -f "$pidfile"
  done
}

start_all() {
  echo "[*] Starting all exporters..."
  for cfg in "$CONFIG_DIR"/prometheus_*.yaml; do
    [[ -f "$cfg" ]] || continue
    qm=$(basename "$cfg" .yaml | sed 's/prometheus_//')
    pidfile="$RUN_DIR/${qm}.pid"

    # 중복 실행 방지
    if [[ -f "$pidfile" ]] && ps -p "$(cat "$pidfile")" > /dev/null 2>&1; then
      echo " - Exporter for $qm already running. Skipping."
      continue
    fi

    logfile="$LOG_DIR/${qm}.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting exporter for $qm" >> "$logfile"
    "$BINARY" -f "$cfg" >> "$logfile" 2>&1 &
    echo $! > "$pidfile"
    echo " - Started exporter for $qm (PID $!)"
  done
}

case "$ACTION" in
  start)
    start_all
    ;;
  stop)
    stop_all
    ;;
  restart)
    stop_all
    sleep 1
    start_all
    ;;
  *)
    echo "Usage: $0 {start|stop|restart} [install_dir]"
    exit 1
    ;;
esac