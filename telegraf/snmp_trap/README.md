# 와탭에서 텔레그래프를 이용한 SNMP TRAP 모니터링

와탭서비스에서 tegegraf 에이전트를 통해 SNMP TRAP을 통해 수신된 임의의 정보를 와탭 수집서버로 업로드 할 수 있습니다. 수집된 정보는 카테고리 telegraf_snmp_trap에서 확인하실 수 있습니다.   

### Prerequisites

지원운영체제
- CentOS/Redhat 6 이상
- Debian 14.04 이상


와탭 연동 telegraf 설치 파일
- http://repo.whatap.io/index.html#telegraf/

와탭 계정 및 프로젝트를 생성합니다.
- [계정생성](https://www.whatap.io)
- [프로젝트 생성](https://service.whatap.io/v2/account/project/list)

### Installing

텔레그래프 설치

|운영체제|Distrubution|설치방법|
|------|---|---|
|Linux|CentOS/Redhat|rpm -Uvh http://repo.whatap.io/telegraf/telegraf-release-1.16.0/linux/amd64/telegraf-1.16.0-1.x86_64.rpm|
|Linux|Debian/Ubuntu|wget http://repo.whatap.io/telegraf/telegraf-release-1.16.0/linux/amd64/telegraf_1.16.0-1_amd64.deb && dpkg -i telegraf_1.12.0~842282d-0_amd64.deb|

리눅스용 실행파일
- http://repo.whatap.io/telegraf/telegraf-release-1.16.0/linux/amd64/telegraf

리눅스 운영체제의 경우 아래파일을 생성합니다. 파일 내용중 한글로 표시된 부분은 실제 내용으로 대체 합나다.
- 파일: /etc/telegraf/telegraf.d/whatap_snmp_trap.conf
- 와탭 라이선스: 프로젝트 선택 후 죄측 메뉴 관리 -> 에이전트 설치 -> 상단탭 Windows 선택 후 화면의 라이선스 복사 합니다.
- 와탭 아이피: 프로젝트 선택 후 죄측 메뉴 관리 -> 에이전트 설치 -> 상단탭 Windows 선택 후 화면의 Whatap IP 복사 합니다.
- 프로젝트 코드: 좌측메뉴 관리>프로젝트 관리에서 확인하실 수 있습니다. 
```
# receive snmp trap
[[inputs.snmp_trap]]
  service_address = "udp://:162"

[[outputs.whatap]]
  license = "와탭 라이선스"
  pcode = 프로젝트 코드
  servers = ["tcp://와탭 아이피:6600"]
```

아래 명령으로 텔레그래프를 재시작 하면 모니터링이 시작됩니다. 
```
service telegraf restart
```


## 와탭에서 수집된 데이터 확인하기

와탭 로그인후 프로젝트 선택시 왼쪽 메뉴의 사이트 맵을 클릭합니다.
태그 카운트 쿼리를 클릭합니다. 

검색 폼에서 아래사항을 입력합니다.
- 시간선택: 조회를 기간을 선택합니다.
- 최대 개수: 한번에 조회하려는 레코드의 최대값을 입력합니다.
- 카테고리: telegraf_snmp_trap
- 검색 버튼(돋보기 아이콘)을 클릭합니다.

