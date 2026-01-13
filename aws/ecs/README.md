# Whatap ECS 태스크 및 사이드카 관리

이 프로그램은 AWS에서 ECS 태스크와 서비스를 생성하고 관리하는 작업을 자동화하는 데 도움이 됩니다. 필요한 IAM 역할, 태스크 정의 및 ECS 서비스를 생성하고, 기존 태스크 정의에 Whatap 사이드카 컨테이너를 추가하는 기능이 포함되어 있습니다.

## 목적

이 프로그램의 목적은 Whatap을 사용하여 ECS 서비스의 배포 및 모니터링을 간소화하는 것입니다. 이를 통해 사용자는 다음을 수행할 수 있습니다:

1. ECS 태스크 정의 및 서비스 생성.
2. ECS 태스크 실행 및 모니터링에 필요한 IAM 역할 관리.
3. 기존 ECS 태스크 정의에 Whatap 사이드카 컨테이너를 추가하여 모니터링을 강화.

## 요구 사항

- Go 프로그래밍 언어 설치.
- AWS CLI 설치 및 적절한 권한으로 구성.
- Whatap 액세스 키 및 호스트 정보.

## 사용법

0.1. **리포지토리 클론**(옵션):
```bash
git clone https://github.com/whatap/tools.git
cd tools/aws/ecs
```
0.2. **프로그램 빌드**(옵션):
```bash
go build -o whatap_ecs ./whatap_ecs.go
```
1. **실행파일 다운로드**:
aws cloud console에서 아래 명령으로 이미 컴파일되어 있는 whatap_ecs를 다운로드 하고 실행할 수 있도록 권한을 부여합니다.
```bash
wget https://github.com/whatap/tools/releases/download/1.0/whatap_ecs
chmod +x whatap_ecs
```   
2. **프로그램 실행**:
```bash
./whatap_ecs
```
프롬프트에 따라 Whatap 액세스 키, 호스트 및 기타 필요한 정보를 입력합니다.

생성된 스크립트 실행:

태스크 정의 생성:
```bash
bash 01_whatap_single_task_definition.sh
```
ECS 서비스 생성:
```bash
bash 02_whatap_single_service.sh
```
기존 태스크 정의에 Whatap 사이드카 추가:
```bash
bash 03_user_task_definition_update.sh
```
