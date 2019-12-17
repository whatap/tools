# 와탭에서 텔레그래프를 이용한 nvidia 모니터링

와탭서비스에서 tegegraf 에이전트를 통해 NVIDIA 그래픽카드가 받는 부하를 실시간 모니터링하고 성능 분석 및 조기경보 받으실 수 있습니다. 와탭에서는 telegraf 연동기능을 통해 NVIDIA 그래픽 카드 자산의 모니터링을 제공하고 있습니다.   

## Getting Started

아래 기술된 방법으로 와탭 프로젝트 설정 및 telegref를 설치 하시면 아래 지수를 수집/챠트보기/알림 적용하실 수 있습니다.
- clocks_current_graphics
- clocks_current_memory
- clocks_current_sm
- clocks_current_video
- encoder_stats_average_fps
- encoder_stats_average_latency
- encoder_stats_session_count
- memory_free
- memory_total
- memory_used
- pcie_link_gen_current
- pcie_link_width_current
- temperature_gpu
- utilization_gpu
- utilization_memory

### Prerequisites

지원운영체제
- CentOS/Redhat 6 이상
- Debian 14.04 이상
- Windows 2008 sp2

Nvidia Tool
- nvidia-smi

Nvidia Driver Download
- https://developer.nvidia.com/cuda-toolkit

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

[[inputs.nvidia_smi]]
  ## Optional: path to nvidia-smi binary, defaults to $PATH via exec.LookPath
  bin_path = "/usr/bin/nvidia-smi"

  ## Optional: timeout for GPU polling
  timeout = "5s"
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

[[inputs.nvidia_smi]]
  ## Optional: path to nvidia-smi binary, defaults to $PATH via exec.LookPath
  bin_path = "C:\\Program Files\\NVIDIA Corporation\\NVSMI\\nvidia-smi.exe"

  ## Optional: timeout for GPU polling
  timeout = "5s"
```

아래 명령을 관리자 권한으로 실행하여 서비스 등록 및 시작합니다.


```
telegraf --service install --config c:\telegraf\whatap_nvidia.conf
telegraf --service start
```

## 와탭에서 수집된 데이터 확인하기

와탭 로그인후 프로젝트 선택시 왼쪽 메뉴의 사이트 맵을 클릭합니다.
태그 카운트 쿼리를 클릭합니다. 

검색 폼에서 아래사항을 입력합니다.
- 시작시간: 조회를 시작하려는 일시를 선택합니다.
- 기간: 조회 기간을 지정합니다. 시작시간 후 지정된 시간만큼을 조회합니다.
- 카테고리: telegraf_nvidia_smi
- 컬럼: ** 혹은 아래 컬럼중 일부를 , 로 연결하여 입력합니다.
```
- clocks_current_graphics
- clocks_current_memory
- clocks_current_sm
- clocks_current_video
- encoder_stats_average_fps
- encoder_stats_average_latency
- encoder_stats_session_count
- memory_free
- memory_total
- memory_used
- pcie_link_gen_current
- pcie_link_width_current
- temperature_gpu
- utilization_gpu
- utilization_memory
```
- 검색 버튼을 클릭합니다.

와탭에서 수집된 데이터 챠트로 보기
와탭 로그인후 프로젝트 선택시 왼쪽 메뉴의 사이트 맵을 클릭합니다.
태그 카운트 챠트를 클릭합니다. 

검색 폼에서 아래사항을 입력합니다.
- 시작시간: 조회를 시작하려는 일시를 선택합니다.
- 기간: 조회 기간을 지정합니다. 시작시간 후 지정된 시간만큼을 조회합니다.
- 카테고리: telegraf_nvidia_smi
- 수준: 위험,경고, 정보중 알림 수신시 표시되는 위험도를 선택합니다.
- 제목: 알림 수신시 메일 및 문자메세지, 메신저에 표시되는 알림 제목을 입력합니다.
- 메세지: 알림 수신시 메일 및 문자메세지, 메신저에 표시되는 알림 내용을 입력합니다.
- 알림 대상을 필터링: 알림 정책이 적용되는 태그정보를 지정하여 적용여부를 제어할 수 있습니다. 태그이름 == '태그값' 의 형식으로 입력합니다.
- 필드와 조건문 입력: 필드 이름과 비교값을 입력하여 조건 부합시 알림을 받으실 수 있습니다. 필드이름 비교부호 비교값(ex. temperature_gpu > 60 )
- 저장 버튼을 클릭하여 저장합니다.
