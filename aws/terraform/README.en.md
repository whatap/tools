# WhaTap ECS Monitoring installation using terraform

Whatap Amazon ECS monitoring collects resource usage per docker container in real-time via META API and Cgroup directory. The Amazon ECS API queries and collects the status of an Amazon ECS Service, Deployment, or Container Instance via an associated WhaTap Task.

## Prerequisites
Software
- Terraform
  
AWS
- AWS IAM (Access/Secret)
  
Whatap Container Image
- whatap/ecs_mon

We recommend that you download the WhaTap container image and register it in your user registry before installing it.

## Monitoring procedure
- Create an integration project in your WhaTap console with Amazon ECS enabled.
- Deploy the WhaTap Amazon ECS agent as a dedicated task or sidecar.

![Whatap ECS Monitoring](https://img.whatap.io/media/images/ecs_fargate_whatap_monitoring_S1OGECY.png "Whatap ECS Monitoring")

## Environment
Modify the variables in the file below to match the target ECS cluster.

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

Input AWS IAM credentials.
#### **`main.tf`**
```
provider "aws" {
  access_key = "xxxxxxxx"
  secret_key = "xxxxxxxxxxxxxxxxxxxxxxx"
  region     = "us-xxxx-x"
}
```

Enter the WhaTap project accesskey and the collector server IP.
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

## Application
Apply the modified terraform.

```
terraform apply
```
