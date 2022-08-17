# Telegraf: influxdb proxy for whatap 


Telegraf 용 Influxdb Input Plugin 및 와탭 Output Plugin을 이용하여 임의의 데이터를 수집하는 방법을 설명합니다 .

## Docker

와탭 Output Plugin이 포함된 Telegraf를 Docker image로 빌드하여 상용환경에 빠르게 설치할 수 있습니다.
### Docker 설치
curl https://get.docker.com | sudo sh -

### 이미지 빌드
docker build -t 태그 .
### 실행
run_telegraf.sh 파일에 와탭 프로젝트 라이선스를 포함한 옵션을 수정 후 실행 합니다.
```
#!/usr/bin/env bash

WHATAP_HOST_IP=
WHATAP_HOST_PORT=6600
WHATAP_PCODE=
WHATAP_LICENSE=
WHATAP_TELEGRAF_IMAGE=registry.whatap.io:5000/telegraf:local
CONTAINER_NAME=whatap_telegraf
...


$sh ./run_telegraf.sh
```

## curl 을 사용한 임의의 데이터 전송
./run_telegraf.sh 를 실행하여 컨테이너가 실행되면 아래 curl 호출로 임의의 성능정보를 와탭으로 전송 할 수 있다. 실제 전송 예는 send_testdata.sh 파일을 참조 할 수 있습니다.

```
#!/usr/bin/env bash
netappInfluxDBURL="localhost"
netappInfluxDBPort=8086

curl -i -XPOST "$netappInfluxDBURL:$netappInfluxDBPort/api/v2/write?precision=s" --data-binary "{와탭 카테고리 이름},{태그1}={값1},{태그2}={값2} {필드1}={숫자 값1},{필드2}={숫자 값2}"
```

## Whatap 설정

임의의 와탭 프로젝트에 임의의 성능 정보를 업로드 하기위해 와탭 콘솔에서 프로젝트를 생성/선택 후 프로젝트 관리 및 에이전트 설치안내 페이지에서 라이선스, 프로젝트 코드 및 수집 서버 주소를 확인할 수 있습니다. 

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


## Inflexdb API 설정

아래 설정은 임의의 성능 정보를 수집하는 Influxdb API InputPlugin을 설정 합니다.

```
[[inputs.influxdb_v2_listener]]
  ## Address and port to host InfluxDB listener on
  ## (Double check the port. Could be 9999 if using OSS Beta)
  service_address = ":8086"
```

 