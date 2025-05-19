#!/usr/bin/env bash
set -e

CMD=$1
QM=$2
CHANNEL=$3
USER=$4
PASSWORD=$5
PROMETHEUS_PORT=$6
MQ_HOST=$7
MQ_PORT=$8

# 기준 디렉토리 자동 추론
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
INSTALL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$INSTALL_DIR/config"
TEMPLATE="$INSTALL_DIR/bin/prometheus.yaml.template"

TELEGRAF_CONF_DIR="/usr/whatap/infra/conf/telegraf.d"
mkdir -p "$TELEGRAF_CONF_DIR"

usage() {
  cat <<EOF
Usage:
  $0 add <QM> <CHANNEL> <USER> <PASSWORD> <PROMETHEUS_PORT> <MQ_HOST> <MQ_PORT>
  $0 remove <QM>
  $0 list
EOF
  exit 1
}

case "$CMD" in
  add)
    [[ -z "$QM" || -z "$CHANNEL" || -z "$USER" || -z "$PASSWORD" || -z "$PROMETHEUS_PORT" || -z "$MQ_HOST" || -z "$MQ_PORT" ]] && usage
    TARGET="$CONFIG_DIR/prometheus_${QM}.yaml"
    TELEGRAF_CONF="$TELEGRAF_CONF_DIR/mq_prometheus_${QM}.conf"

    if [[ -e "$TARGET" ]]; then
      echo "Error: $TARGET already exists." >&2
      exit 2
    fi

    # MQ Exporter 설정 파일 생성
    cp "$TEMPLATE" "$TARGET"
    sed -i "s/{{QM}}/${QM}/g" "$TARGET"
    sed -i "s/{{CHANNEL}}/${CHANNEL}/g" "$TARGET"
    sed -i "s/{{USER}}/${USER}/g" "$TARGET"
    sed -i "s/{{PASSWORD}}/${PASSWORD}/g" "$TARGET"
    sed -i "s/{{PROMETHEUS_PORT}}/${PROMETHEUS_PORT}/g" "$TARGET"
    sed -i "s/{{MQ_HOST}}/${MQ_HOST}/g" "$TARGET"
    sed -i "s/{{MQ_PORT}}/${MQ_PORT}/g" "$TARGET"
    echo "Added configuration: $TARGET"

    # Telegraf 설정 파일 생성
    cat > "$TELEGRAF_CONF" <<EOF
[[inputs.prometheus]]
  urls = ["http://localhost:${PROMETHEUS_PORT}/metrics"]
  metric_version = 1
EOF
    echo "Added Telegraf configuration: $TELEGRAF_CONF"
    ;;

  remove)
    [[ -z "$QM" ]] && usage
    TARGET="$CONFIG_DIR/prometheus_${QM}.yaml"
    TELEGRAF_CONF="$TELEGRAF_CONF_DIR/mq_prometheus_${QM}.conf"

    if [[ ! -e "$TARGET" ]]; then
      echo "Error: $TARGET does not exist." >&2
      exit 2
    fi

    # MQ Exporter 설정 파일 삭제
    rm -f "$TARGET"
    echo "Removed configuration: $TARGET"

    # Telegraf 설정 파일 삭제
    if [[ -e "$TELEGRAF_CONF" ]]; then
      rm -f "$TELEGRAF_CONF"
      echo "Removed Telegraf configuration: $TELEGRAF_CONF"
    fi
    ;;

  list)
    ls "$CONFIG_DIR"/prometheus_*.yaml 2>/dev/null | sed 's#.*/prometheus_\(.*\)\.yaml#\1#'
    ;;

  *)
    usage
    ;;
esac

if systemctl list-units --type=service | grep -q whatap_mq.service; then
  echo "Reloading exporters..."
  systemctl reload whatap_mq.service
else
  echo "Warning: whatap_mq.service not found. Skipping reload."
fi