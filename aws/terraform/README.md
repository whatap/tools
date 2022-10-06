# 테라폼을 사용한 와탭 ECS모니터링 설치

와탭 Amazon ECS모니터링은 META API 및 Cgroup 디렉토리를 통해 도커 컨테이너별 자원 사용량을 실시간으로 수집합니다. Amazon ECS API 연동 와탭 Task를 통해 Amazon ECS Service, Deployment, Container Instance의 상태를 조회 및 수집합니다.

## Prerequisites
Software
- Terraform
  
AWS
- AWS IAM (Access/Secret)
  
Whatap Container Image
- whatap/ecs_mon

설치에 쓰이는 와탭 컨테이너 이미지는 다운로드 후 사용자 레지스트리에 등록 후 사용 하시는 것을 권장합니다.

## 모니터링 절차
- 사용자 와탭 콘솔에서 인티그레이션 프로젝트를 Amazon ECS 사용 상태로 생성 합니다.
- 와탭 Amazon ECS 에이전트를 전용 Task 혹은 Sidecar 로 배포 합니다.

![와탭 ECS 모니터링](https://img.whatap.io/media/images/ecs_fargate_whatap_monitoring_S1OGECY.png "와탭 ECS 모니터링")

## 환경설정
아래 파일의 변수를 목표 ECS클러스터에 맞게 수정 합니다.

#### **`common_variables.tf`**
```
variable "region" {
  default = "us-xxxx-x"
}
variable "clusterarn" {
    default = "arn:aws:ecs:us-xxxx-x:xxxxxxx:cluster/xxxxxxx"
}
variable "vpc" {
    default = "vpc-xxxxxxx"
}

variable "sg-group" {
    default = "sg-xxxxxxxxxxx"
}

variable "subnet1" {
    default = "subnet-xxxxxxxxxx"
}

variable "subnet2"{
    default = "subnet-xxxxxxxxxxxx"
}
```

AWS IAM 인증정보를 입력합니다.
#### **`main.tf`**
```
provider "aws" {
  access_key = "xxxxxxxx"
  secret_key = "xxxxxxxxxxxxxxxxxxxxxxx"
  region     = "us-xxxx-x"
}
```

와탭 프로젝트의 accesskey와 수집서버 IP 를 입력합니다.
#### **`whatap_variable.tf`** 
```
variable "whatapsingle" {
  default = "whatap-single"
}

variable "whatap_accesskey" {
    default = "xxxx-xxxx-xxxx"
}

variable "whatap_host" {
    default = "x.x.x.x"
}
```

## 적용
수정한 테라폼을 적용합니다.

```
terraform apply
```
