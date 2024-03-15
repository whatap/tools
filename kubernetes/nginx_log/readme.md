# Nginx와 Whatap 로그 수집기 설정 가이드

이 가이드는 Kubernetes 환경에서 Nginx 서버 로그를 수집하고 모니터링하기 위한 Whatap 로그 수집기의 설정 방법을 설명합니다. Whatap을 사용하여 Nginx 액세스 로그를 수집, 분석하고 실시간으로 모니터링할 수 있습니다.

## 전제 조건

- Kubernetes 클러스터가 설정되어 있어야 합니다.
- Whatap 서버 모니터링 프로젝트가 생성되어 있어야 합니다.

## 설정 단계

### 1. Whatap 프로젝트 엑세스 키와 수집 서버 IP 확인

Whatap 프로젝트를 생성한 후, 설치 안내에서 제공하는 **엑세스 키**와 **수집서버 IP**를 확인합니다. 이 정보는 Whatap 로그 수집기 컨테이너를 구성할 때 사용됩니다.

### 2. ConfigMap 생성

Nginx 로그 파일 경로와 관련 설정을 포함하는 ConfigMap을 생성합니다. 이 ConfigMap은 Whatap 로그 수집기에 의해 참조됩니다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: whatap-log-config
data:
  accesslog.conf: |-
    [[inputs.logsink]]
      category = "nginxlog"
      stats_enabled = true 
      stats_category = "logsink_stats"
      excludeNames = [ ".gz",".zip" ] 
      [[inputs.logsink.file]]
        path = "/var/log/nginx/access.log" 
        disabled = false
        encoding = "utf-8"
```

### 3. Deployment 생성

Nginx와 Whatap 로그 수집기 컨테이너를 포함하는 Deployment를 생성합니다. 이 Deployment는 로그를 공유 볼륨에 쓰고 Whatap 로그 수집기가 이를 수집하도록 구성됩니다.

- `WHATAP_ACCESSKEY`: Whatap 프로젝트 엑세스 키로 치환합니다.
- `WHATAP_SERVER_HOST`: Whatap 수집서버 IP로 치환합니다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      volumes:
      - name: shared-logs
        emptyDir: {}
      - name: whatap-log-config
        configMap:
          defaultMode: 0700
          name: whatap-log-config
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx
      - name: whatap-log-collector
        image: whatap/server_mon:amd64
        imagePullPolicy: Always
        env:
        - name: WHATAP_ACCESSKEY
          value: "와탭 프로젝트 엑세스 키"
        - name: WHATAP_SERVER_HOST
          value: "와탭 수집서버 아이피"
        volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx
        - name: whatap-log-config
          mountPath: /usr/whatap/infra/extension/accesslog.conf
          readOnly: true
          subPath: accesslog.conf
        resources:
          limits:
            memory: "64Mi"
            cpu: "100m"
```

### 4. Nginx 컨테이너 설정

Nginx 컨테이너의 설정은 기존에 사용하고 있던 설정을 그대로 사용합니다. `access.log` 파일의 위치는 `/var/log/nginx`로 가정합니다.

### 5. 로그 파일 Rotation 설정

`access.log` 파일의 로그 Rotation은 Nginx 설정을 통해 최소로 설정할 수 있습니다. 이는 서버의 저장 공간을 효율적으로 관리하는 데 도움이 됩니다.

## 배포

설정이 완료된 후, Kubernetes 클러스터에 이 YAML 파일을 배

포합니다. 다음 명령어를 사용하여 배포할 수 있습니다:

```sh
kubectl apply -f <파일명>.yaml
```

이제 Nginx 로그가 Whatap으로 수집되어 실시간 모니터링 및 분석이 가능합니다.