# Telegraf: snmp monitoring for whatap 


Telegraf 용 와탭 Output Plugin을 이용하여 빠르게 SNMP 모니터링을 적용하는 방법을 설명합니다 .

## Docker

snmptranslate, snmptable명령 및 기본 MIB를 Docker image로 빌드하여 원라인으로 설치할 수 있습니다.
### Docker 설치
curl https://get.docker.com | sudo sh -

### 이미지 빌드
docker build -t 태그 .
### 실행
run.sh 파일에 와탭 프로젝트 라이선스를 포함한 옵션을 수정 후 실행 합니다.
```
#!/usr/bin/env bash

WHATAP_HOST_IP=
WHATAP_HOST_PORT=6600
WHATAP_PCODE=
WHATAP_LICENSE=
SNMP_DEVICE_IP=
WHATAP_TELEGRAF_IMAGE=registry.whatap.io:5000/dev/telegraf:2000004041
SNMP_COMMUNITY=public
SNMP_VERSION=2
CONTAINER_NAME=whatap_telegraf
...


$sh ./run.sh
```


## Whatap 설정

임의의 와탭 프로젝트에 SNMP 성능 정보를 업로드 하기위해 와탭 콘솔에서 프로젝트를 생성/선택 후 프로젝트 관리 및 에이전트 설치안내 페이지에서 라이선스, 프로젝트 코드 및 수집 서버 주소를 확인할 수 있습니다. 

```
[[outputs.whatap]]
#   ## WhaTap license. Required
    license = "$WHATAP_LICENSE"
#   ## WhaTap project code. Required
    pcode = $WHATAP_PCODE
#
#   ## WhaTap server IP. Required
    servers = ["tcp://$WHATAP_HOST_IP:$WHATAP_HOST_PORT"]
#
#   ## Connection timeout.
#   # timeout = "60s"
```


## SNMP 설정

아래 설정은 스위치 네트워크 장치의 포트별 성능정보를 수집합니다. 초당 성능을 계산하기 위해 starlark 플러그인을 사용하여 Octets_rate로 끝나는 필드를 재계산 합니다.

```
[[inputs.snmp]]
  ## Agent addresses to retrieve values from.
  ##   format:  agents = ["<scheme://><hostname>:<port>"]
  ##   scheme:  optional, either udp, udp4, udp6, tcp, tcp4, tcp6.
  ##            default is udp
  ##   port:    optional
  ##   example: agents = ["udp://127.0.0.1:161"]
  ##            agents = ["tcp://127.0.0.1:161"]
  ##            agents = ["udp4://v4only-snmp-agent"]

  agents = ["udp://$SNMP_DEVICE_IP:161"]

  ## Timeout for each request.
  # timeout = "5s"

  ## SNMP version; can be 1, 2, or 3.
   version = $SNMP_VERSION

  ## SNMP community string.
   community = "$SNMP_COMMUNITY"

  ## Agent host tag
  # agent_host_tag = "agent_host"

  ## Number of retries to attempt.
  # retries = 3

  ## The GETBULK max-repetitions parameter.
  # max_repetitions = 10

  ## SNMPv3 authentication and encryption options.
  ##
  ## Security Name.
  # sec_name = "myuser"
  ## Authentication protocol; one of "MD5", "SHA", "SHA224", "SHA256", "SHA384", "SHA512" or "".
  # auth_protocol = "MD5"
  ## Authentication password.
  # auth_password = "pass"
  ## Security Level; one of "noAuthNoPriv", "authNoPriv", or "authPriv".
  # sec_level = "authNoPriv"
  ## Context Name.
  # context_name = ""
  ## Privacy protocol used for encrypted messages; one of "DES", "AES", "AES192", "AES192C", "AES256", "AES256C", or "".
  ### Protocols "AES192", "AES192", "AES256", and "AES256C" require the underlying net-snmp tools
  ### to be compiled with --enable-blumenthal-aes (http://www.net-snmp.org/docs/INSTALL.html)
  # priv_protocol = ""
  ## Privacy password used for encrypted messages.
  # priv_password = ""

  ## Add fields and tables defining the variables you wish to collect.  This
  ## example collects the system uptime and interface variables.  Reference the
  ## full plugin documentation for configuration details.
  [[inputs.snmp.field]]
    oid = "RFC1213-MIB::sysUpTime.0"
    name = "uptime"

  [[inputs.snmp.field]]
    oid = "RFC1213-MIB::sysName.0"
    name = "source"
    is_tag = true

  [[inputs.snmp.table]]
    oid = "IF-MIB::ifXTable"
    name = "interface"
    inherit_tags = ["source"]

  [[inputs.snmp.table.field]]
    oid = "IF-MIB::ifDescr"
    name = "ifDescr"
    is_tag = true

  [[aggregators.derivative]]
    period = "60s"
    max_roll_over = 1

    fieldpass = ["*Octets", "*Pkts"]
    drop_original = false

  [aggregators.derivative.tags]
    aggr = "derivative"

[[processors.starlark]]
  source = '''
def apply(metric):
    for (k, v) in metric.fields.items():
        if k.endswith('Octets_rate'):
            metric.fields[k] *= 8

    return metric
```

## SNMP TRAP 설정
특정 포트로 snmp trap 이벤트를 수신할 수 있습니다.
```
[[inputs.snmp_trap]]
  service_address = "udp://:162"
  path = ["/usr/share/snmp/mibs"]
  ```
