#!/usr/bin/env bash
set -e

# Usage: install.sh [install_dir] [WHATAP_SERVER_HOST] [LICENSE]
INSTALL_DIR=${1:-/opt/whatap_mq}
WHATAP_SERVER_HOST=${2}
LICENSE=${3}

if [[ -z "$WHATAP_SERVER_HOST" || -z "$LICENSE" ]]; then
  echo "Usage: $0 [install_dir] <WHATAP_SERVER_HOST> <LICENSE>"
  exit 1
fi

CONFIG_DIR="$INSTALL_DIR/config"
SERVICE_FILE=/etc/systemd/system/whatap_mq.service

echo "Installing to: $INSTALL_DIR"

# 1) 설치 디렉토리 준비
mkdir -p "$INSTALL_DIR/bin" "$CONFIG_DIR"
chmod -R +rx "$INSTALL_DIR"

# 2) 바이너리 및 스크립트 복사
cp -r mqm "$INSTALL_DIR/"
cp mq_prometheus prometheus.yaml.template whatap_mq_master.sh whatap_mq_ctl.sh "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin/whatap_mq_master.sh" "$INSTALL_DIR/bin/whatap_mq_ctl.sh"

# 3) systemd 서비스 단일화 유닛 생성
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Whatap IBM MQ Exporter Manager
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$INSTALL_DIR/bin/whatap_mq_master.sh start "$INSTALL_DIR"
ExecStop=$INSTALL_DIR/bin/whatap_mq_master.sh stop "$INSTALL_DIR"
ExecReload=$INSTALL_DIR/bin/whatap_mq_master.sh restart "$INSTALL_DIR"
User=root
Environment=MQ_INSTALLATION_PATH=$INSTALL_DIR/mqm
Environment=LD_LIBRARY_PATH=$INSTALL_DIR/mqm/lib64

[Install]
WantedBy=multi-user.target
EOF

# 4) systemd 리로드 및 서비스 등록
systemctl daemon-reload
systemctl enable whatap_mq.service
systemctl start whatap_mq.service

# 5) 와탭 인프라 에이전트 설치
echo "[*] Installing Whatap Infra Agent package..."
dpkg -i whatap-infra_2.8.6_amd64.deb

# 6) Telegraf 파일 복사
echo "[*] Copying Telegraf binary..."
cp telegraf /usr/whatap/infra/

# 7) 와탭 에이전트 설정
WHATAP_CONF=/usr/whatap/infra/conf/whatap.conf
echo "[*] Configuring Whatap Agent at $WHATAP_CONF..."
mkdir -p /usr/whatap/infra/conf/telegraf.d
cat > "$WHATAP_CONF" <<EOF
license=$LICENSE
whatap.server.host=$WHATAP_SERVER_HOST
createdtime=$(date +%s%N)
internal.forwarder.enabled=true
telegraf.sidecar.enabled=true
telegraf.sidecar.executable=/usr/whatap/infra/telegraf
EOF

echo "Installation complete."
echo "Use $INSTALL_DIR/bin/whatap_mq_ctl.sh <add|remove|list> to manage QMs,"
echo "and control service with: systemctl {start|stop|reload} whatap_mq"
