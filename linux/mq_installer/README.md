# Whatap IBM MQ Exporter for Prometheus
IBM MQ 성능 모니터링을 위한 Whatap Exporter 설치 및 설정 가이드

## ✅ 사전 요구사항
- **운영체제**: Ubuntu 22.04 (64bit)
- **메모리**: 최소 200MB 이상 여유
- **IBM MQ**: 클라이언트 접속이 가능한 SVRCONN 채널 사전 구성 필요
- **root 권한** 필요

## ✅ 시스템 아키텍처
```
+-------------------+      +---------------------------+      +-------------------+
|  Whatap Infra     | ---> |  MQ Exporter (Prometheus)  | ---> |  IBM MQ Queue     |
|  Agent (Telegraf) |      |  (Per Queue Manager)      |      |  Manager          |
|                   | <--- |  http://localhost:{port}/metrics  |                   |
+-------------------+      +---------------------------+      +-------------------+
         │
         │ (Metric Forwarding)
         ▼
+-------------------+
| Whatap SaaS/Server|
+-------------------+
```

## ✅ 1. 설치
아래 명령을 실행해 Exporter와 Whatap Infra Agent를 설치합니다.

```bash
wget https://repo.whatap.io/telegraf/feature/ibmmq/whatap_mq_exporter_installer.run
chmod +x whatap_mq_exporter_installer.run
sudo ./whatap_mq_exporter_installer.run /usr/whatap/whatap_mq <WHATAP_SERVER_HOST> <LICENSE_KEY>
```

### 파라미터 설명
- **/usr/whatap/whatap_mq** : 설치 경로 (권장: /usr/whatap/whatap_mq)
- **<WHATAP_SERVER_HOST>**   : 와탭 수집 서버의 IP 또는 Host:Port (예: 15.165.146.117)
- **<LICENSE_KEY>**          : 와탭 라이선스 키

설치가 완료되면 `whatap_mq` 서비스가 자동 시작됩니다.

## ✅ 2. IBM MQ Queue Manager 추가
Queue Manager 별로 exporter를 추가합니다.  
**반드시 Queue Manager 마다 반복**해야 하며, **SVRCONN 타입 채널**이 필요합니다.

### MQ 채널 예시 생성 명령 (MQ 관리자 쉘에서 실행)
```bash
DEFINE CHANNEL(APP.CH.SVR6) CHLTYPE(SVRCONN) TRPTYPE(TCP)
```

### Exporter 등록 명령
```bash
sudo /usr/whatap/whatap_mq/bin/whatap_mq_ctl.sh add <QM_NAME> <CHANNEL> <USER> <PASSWORD> <EXPORTER_PORT> <MQ_HOST> <MQ_PORT>
```

#### 예시
```bash
sudo /usr/whatap/whatap_mq/bin/whatap_mq_ctl.sh add QM7 APP.CH.SVR6 whatap_user 'password' 9158 192.168.1.156 1415
```

## ✅ 3. Queue Manager 제거 (선택)
더 이상 필요 없는 Queue Manager 설정을 제거할 수 있습니다.

```bash
sudo /usr/whatap/whatap_mq/bin/whatap_mq_ctl.sh remove <QM_NAME>
```

#### 예시
```bash
sudo /usr/whatap/whatap_mq/bin/whatap_mq_ctl.sh remove QM7
```

## ✅ 4. Exporter 전체 제어
Exporter 전체 시작 또는 중지 명령은 다음과 같습니다.

- **정지**
  ```bash
  sudo systemctl stop whatap_mq
  ```

- **시작**
  ```bash
  sudo systemctl start whatap_mq
  ```

## ✅ 5. 대시보드 추가 (Flexboard)
Whatap Flexboard에서 다음 JSON 대시보드를 **가져오기**로 불러와 적용합니다.

- **IBM MQ Overview.json**
- **IBM MQ Channel Status.json**
