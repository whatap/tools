# 쿠버네티스 클러스터에 운영중인 파이썬 어플리케이션에 와탭 에이전트 설치 

파이썬 어플리케이션에 와탭 에이전트를 설치 할 수 있습니다.   

## Dockerfile

파이썬 어플리케이션 빌드시 whatap-python 패키지를 설치합니다.
```
FROM python:3.7
...
RUN pip3 install --upgrade whatap-python
...
```

## Entrypoint
파이썬 어플리케이션 시작시 와탭 에이전트가 Injection할 수 있도록 어플리케이션 시작 스크립트를 변경합니다.
수집서버IP 및 프로젝트 라이선스는 왼쪽 메뉴 설정 -> 에이전트 추가에서 확인하실 수 있습니다.
```
#설정 파일 및 로그 출력 디렉토리를 환경변수 WHATAP_HOME으로 설정합니다.
export WHATAP_HOME=/whatap_conf

#설정파일을 생성합니다.
whatap-setting-config --host 수집서버IP --license 프로젝트라이선스 --app_name 업무명 --app_process_name HTTP서버

#와탭 에이전트가 사용자의 어플리케이션을 시작하게 합니다.    
whatap-start-agent gunicorn -b 0.0.0.0:8000 --workers=3 django1.wsgi
```

## Kubernetes 환경변수 및 볼륨
트랜잭션에서 NODE 및 POD정보를 수집하기 위해 NODE_IP, NODE_NAME, POD_NAME을 환경변수로 설정합니다. 
와탭 설정파일 및 로그파일용 휘발성 볼륨을 탑재합니다.

```
apiVersion: apps/v1
kind: ReplicaSet
...  
spec:
  ...
  template:
    ...
    spec:
      containers:
        - name: xxxxxx
          ...
          env:
            - name: NODE_IP
              valueFrom: {fieldRef: {fieldPath: status.hostIP}}
            - name: NODE_NAME
              valueFrom: {fieldRef: {fieldPath: spec.nodeName}}
            - name: POD_NAME
              valueFrom: {fieldRef: {fieldPath: metadata.name}}
            - name: REDIS_HOST
          volumeMounts:
            ...
            - name: whatap-config-volume
              mountPath: /whatap_conf
      volumes:
        - name: whatap-config-volume
          emptyDir: {}            
```

## 어플리케이션 배포
빌드한 Docker Image로 POD를 새로 배포하면 파이썬 어플리케이션에서 발생하는 트랜잭션을 모니터링하실 수 있습니다.