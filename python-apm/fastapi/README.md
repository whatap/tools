# docker를 사용한 와탭 python APM 에이전트 설치

Docker 환경에서 와탭 APM 에이전트를 설치하는 단계를 설명합니다. 

## Prerequisites
Network
- pipy(https://pypi.org/project/whatap-python) 인터넷 접속

Software
- python3, pip, docker
  


## 모니터링 절차
- 와탭 파이썬 프로젝트를 만들고 액세스 키를 발급합니다.
- 설치 안내에 따라 whatap.conf 파일을 생성합니다. 
- 와탭 에이전트를 포함하여 최종 사용자 어플리케이션 컨테이너 이미지를 빌드 합니다.
- 컨테이너를 실행하면 와탭 모니터링에 자동으로 등록됩니다.


#### **`Dockerfile`**
```
from xxxx
...
ENV WHATAP_HOME=/whatap
WORKDIR /whatap
ADD . .
RUN pip install whatap-python
RUN whatap-setting-config \
--host {설치안내의 수집서버 아아피} \
--license {설치안내의 액세스 키} \
--app_name {어플리케이션 이름} \
--app_process_name uvicorn
RUN echo "옵션추가" >> whatap.conf
...

CMD ["whatap-start-agent", "uvicorn", "main:app", "--host=0.0.0.0", "--port=8000"]

```

## 적용
이미지를 빌드하고 컨테이너를 시작합니다.

```
docker build -t myimage:version .

docker run --name myapp -d myimage:version
```
