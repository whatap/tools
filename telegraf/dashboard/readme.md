# 와탭에서 텔레그래프를 이용한 대시보드 구성

와탭서비스에서 tegegraf 에이전트를 통해 수집된 데이터를 이용해 사용자 대시보드를 구성할 수 있습니다.   

## Getting Started

아래 기술된 방법으로 설정하시면 aws cloudwatch EFS 모니터링 데이터를 telegref로 수집된 데이터의 챠트표시가 가능합니다.

### Prerequisites

지원운영체제
- CentOS/Redhat 6 이상
- Debian 14.04 이상
- Windows 2008 sp2

와탭 연동 telegraf 설치 파일
- http://repo.whatap.io/index.html#telegraf/

와탭 계정 및 프로젝트를 생성합니다.
- [계정생성](https://www.whatap.io)
- [프로젝트 생성](https://service.whatap.io/v2/account/project/list)

### Installing

텔레그래프 설치

|운영체제|Distrubution|설치방법|
|------|---|---|
|Linux|CentOS/Redhat|rpm -Uvh http://repo.whatap.io/telegraf/linux/amd64/telegraf-1.12.0~842282d-0.x86_64.rpm|
|Linux|Debian/Ubuntu|wget http://repo.whatap.io/telegraf/linux/amd64/telegraf_1.12.0~842282d-0_amd64.deb && dpkg -i telegraf_1.12.0~842282d-0_amd64.deb|
|Windows|Windows 2008 SP2 이상|telegraf install --config telegraf.conf|

리눅스 운영체제의 경우 아래파일을 생성합니다. 파일 내용중 한글로 표시된 부분은 실제 내용으로 대체 합나다.
- 파일: /etc/telegraf/telegraf.d/whatap_nvidia.conf
- 와탭 라이선스: 프로젝트 선택 후 죄측 메뉴 관리 -> 에이전트 설치 -> 상단탭 Windows 선택 후 화면의 라이선스 복사 합니다.
- 와탭 아이피: 프로젝트 선택 후 죄측 메뉴 관리 -> 에이전트 설치 -> 상단탭 Windows 선택 후 화면의 Whatap IP 복사 합니다.
- 프로젝트 코드: 상단 주소상의 숫자부분을 복사합니다. 예.) https://service.whatap.io/v2/project/sms/프로젝트 코드/server/register 
```
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  hostname = ""
  omit_hostname = false

[[outputs.whatap]]
  license = "와탭 라이선스"
  pcode = 프로젝트 코드
  servers = ["tcp://와탭 아이피:6600"]
# Pulls statistics from nvidia GPUs attached to the host

[[inputs.cloudwatch]]
      region = "아마존 리전"
      access_key = "IAM 액세스 키"
      secret_key = "IAM 시크릿"
      period = "1m"
      delay = "1m"
      interval = "1m"
      namespace = "AWS/EFS"
```

아래 명령으로 텔레그래프를 재시작 하면 모니터링이 시작됩니다. 
```
service telegraf restart
```

윈도우 운영체제의 경우 아래파일을 생성합니다. 윈도우의 경우 설치 디렉토리는 임의의 폴더를 선택하시면 됩니다.
파일 내용중 한글로 표시된 부분은 실제 내용으로 대체 합나다.
- 파일: c:\telegraf\whatap_nvidia.conf
- 와탭 라이선스: 프로젝트 선택 후 죄측 메뉴 관리 -> 에이전트 설치 -> 상단탭 Windows 선택 후 화면의 라이선스 복사 합니다.
- 와탭 아이피: 프로젝트 선택 후 죄측 메뉴 관리 -> 에이전트 설치 -> 상단탭 Windows 선택 후 화면의 Whatap IP 복사 합니다.
- 프로젝트 코드: 상단 주소상의 숫자부분을 복사합니다. 예.) https://service.whatap.io/v2/project/sms/프로젝트 코드/server/register 
```
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  hostname = ""
  omit_hostname = false

[[outputs.whatap]]
  license = "와탭 라이선스"
  pcode = 프로젝트 코드
  servers = ["tcp://와탭 아이피:6600"]
# Pulls statistics from nvidia GPUs attached to the host

[[inputs.cloudwatch]]
      region = "아마존 리전"
      access_key = "IAM 액세스 키"
      secret_key = "IAM 시크릿"
      period = "1m"
      delay = "1m"
      interval = "1m"
      namespace = "AWS/EFS"
```

아래 명령을 관리자 권한으로 실행하여 서비스 등록 및 시작합니다.


```
telegraf --service install --config c:\telegraf\whatap_nvidia.conf
telegraf --service start
```

## 와탭에서 수집된 데이터로 대시보드 구성하기

와탭 로그인후 프로젝트 선택시 왼쪽 메뉴의 사이트 맵을 클릭합니다.
태그 카운트 보드를 클릭합니다. 

- 대시보드 생성하기 버튼을 클릭합니다. 
- 팝업창에서 이름과 설명을 입력 후 확인을 클릭 합니다.
- 목록에서 입력한 이름을 클릭합니다.
- 수정 모드를 클릭하면 우측에 위젯 추가 버튼이 보입니다.
- 위젯 추가 버튼을 클릭하면 화면에 챠트가 추가되는것을 확인할 수 있습니다.
- 챠트 메뉴(햄버거 버튼)에서 수정을 클릭합니다.
- 팝업 하단의 Add Data 버튼을 클릭하면 
