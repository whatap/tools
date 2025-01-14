# 와탭 로그 기능을 활용한 리눅스 SSH 세션 기록 모니터링

이 문서에서는 와탭 로그 기능을 활용해서 리눅스 SSH 세션 기록을 모니터링하는 방법을 설명합니다. 먼저 `auditd`를 설치하고 SSH 세션을 기록하는 방법을 설명합니다. `auditd`는 리눅스에서 시스템 활동을 감시하고 기록할 수 있는 강력한 도구입니다. SSH 세션에 대한 기록을 남기려면 `auditd`를 설정하고 규칙을 추가하여 SSH 연결 및 활동을 추적해야 합니다. 

---

## 1. `auditd` 설치

### Ubuntu/Debian 기반 시스템
```bash
sudo apt update
sudo apt install auditd audispd-plugins -y
```
CentOS/RHEL 기반 시스템
```bash
sudo yum install auditd audispd-plugins -y
```
설치 후, auditd 서비스가 자동으로 시작되며, 부팅 시 자동으로 시작되도록 설정됩니다.

## 2. auditd 서비스 확인 및 시작
설치가 완료된 후 auditd 서비스가 실행 중인지 확인하고, 실행되지 않았다면 시작합니다.

서비스 상태 확인
```bash
sudo systemctl status auditd
```
서비스 시작
```bash
sudo systemctl start auditd
```
서비스 자동 시작 설정
```bash
sudo systemctl enable auditd
```
## 3. SSH 세션 기록을 위한 auditd 규칙 추가
auditd는 기본적으로 시스템 이벤트를 기록하는 도구입니다. SSH 세션 기록을 위해서는 auditd의 규칙 파일에 세션에 관련된 항목을 추가해야 합니다.

### 3.1. 규칙 파일 편집
/etc/audit/rules.d/ 디렉토리로 이동하여 audit.rules 파일을 편집합니다.
```bash
sudo nano /etc/audit/rules.d/audit.rules
```
SSH 관련 로그를 추가합니다. 아래와 같이 SSH 연결에 대한 활동을 추적할 수 있는 규칙을 추가합니다:
```bash
# SSH 연결에 대한 활동 기록
-w /etc/ssh/sshd_config -p wa -k ssh_changes
-w /var/log/auth.log -p wa -k ssh_logs
```
이 규칙은 SSH 설정 파일(/etc/ssh/sshd_config)의 변경과 인증 로그(/var/log/auth.log)에 대한 기록을 추적합니다. -w는 파일을 감시하고, -p는 파일에 대한 접근 권한을 설정하는 옵션입니다. -k는 추적하려는 이벤트에 대한 키를 지정합니다.
### 3.2. 규칙 적용
규칙을 추가한 후 auditd 서비스를 재시작하여 변경 사항을 적용합니다.

```bash
sudo systemctl restart auditd
```

## 4. auth.log 파일을 와탭 로그 모니터링 설정하기
### 4.1. 서버 모니터링 에이전트 설정

```bash

cd /usr/whatap/infra
sudo mkdir extension

cat <<EOL | sudo tee extension/logsink_auth.conf > /dev/null
[[inputs.logsink]]
  category = "authlog"
  stats_enabled = true 
  stats_category = "logsink_stats"
  [[inputs.logsink.file]]
    path = "/var/log/auth.log" 
    disabled = false
    encoding = "utf-8"
EOL

sudo service whatap-infra restart

```
### 4.2. 로그 파서 패턴 등록
와탭 웹 콘솔에서 좌측메뉴 로그 > 로그 설정에서 로그 1차 파서에 아래 파서를 추가할 수 있습니다.
```bash
[
  {
    "category": "authlog",
    "enabled": true,
    "filter": "",
    "pattern": "%{SYSLOGTIMESTAMP:local_timestamp}\\s+%{HOSTNAME:hostname}\\s+%{WORD:process}:\\s+%{USERNAME:user}\\s*:\\s*TTY=\\s*%{NOTSPACE:tty}\\s*;\\s*PWD=\\s*%{NOTSPACE:pwd}\\s*;\\s*USER=\\s*%{USERNAME:target_user}\\s*;\\s*COMMAND=\\s*%{GREEDYDATA:command}"
  }
]
```
[logparser.json 파일 다운로드](./logparser.json)

