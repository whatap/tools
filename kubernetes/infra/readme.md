# 와탭 서버 모니터링 오픈시프트 적용
와탭 서버 모니터링 에이전트를 쿠버네티스에서 데몬셋으로 적용할 수 있습니다.
데몬셋 적용시 노드마다 컨테이너가 생성됩니다. 호스트 머신의 파일에 로그 모니터링을 적용하기 위해서는 컨테이너에 호스트 머신의 디렉토리를 탑재하여 컨테어너 프로세스가 호스트 머신 파일에 접근 가능하도록 설정하실 수 있습니다.

## 와탭 수집 서버 정보 적용
아래와 같이 다운받은 yaml 파일에 와탭 라이선스와 수집서버 아이피를 수정하고 저장합니다.
```
vi whatap_server_monitoring.yaml
...
          env:
            - name: WHATAP_LICENSE
              value: "와탭 라이선스"
            - name: WHATAP_HOST
              value: "와탭 수집서버 아이피"

...
```

## 적용방법
호스트머신의 디렉토리를 컨테이너 마운트에 필요한 권한 설정을 아래와 같이 적용합니다. 
```
oc create -f whatap_openshift_scc.yaml
```
데몬셋으로 서버 모니터링 POD를 생성합니다. 서버이름은 노드 이름으로 적용됩니다.
```
kubectl apply -f whatap_server_monitoring.yaml
```

적용이 완료되면 호스트머신의 파일시스템이 /hostfs 에 읽기 전용으로 탑재됩니다.
와탭 서버모니터링 좌측 메뉴 알림 설정 선택후 로그 모니터링 설정을 입력할 때 프로젝트 기본 설정으로 적용하시면 노드의 추가 삭제시 자동으로 적용될 수 있습니다. 
```
hostfs
|-- bin -> usr/bin
|-- boot
|-- dev
|-- etc
|-- home -> var/home
|-- lib -> usr/lib
|-- lib64 -> usr/lib64
|-- media -> run/media
|-- mnt -> var/mnt
|-- opt -> var/opt
|-- ostree -> sysroot/ostree
|-- proc
|-- root -> var/roothome
|-- run
|-- sbin -> usr/sbin
|-- srv -> var/srv
|-- sys
|-- sysroot
|-- tmp
|-- usr
`-- var
```

