# Terraformを利用したWhaTap ECSモニタリングのインストール

WhaTap Amazon ECSモニタリングは、META APIおよびCgroupディレクトリからDockerコンテナ毎のリソース使用量をリアルタイムで収集します。Amazon ECS API連携WhaTap TaskからAmazon ECS Service、Deployment、Container Instanceの状態を照会および収集します。

## Prerequisites
Software
- Terraform
  
AWS
- AWS IAM (Access/Secret)
  
WhaTap Container Image
- whatap/ecs_mon

インストールする際に使うWhaTapコンテナイメージは、ダウンロード後ユーザーレジストリに登録してから利用するのをお勧めします。

## モニタリングの手順
- WhaTapのユーザーコンソールにログインし、Amazon ECSプロジェクトを生成します。
- WhaTap Amazon ECSエージェントを専用のTask もしくは Sidecar で配布します。

![WhaTap ECSモニタリング](https://img.whatap.io/media/images/ecs_fargate_whatap_monitoring_S1OGECY.png "WhaTap ECSモニタリング")

## 環境設定
以下のファイルの変数をモニタリング対象のECSクラスターに合わせて修正します。

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

AWS IAM認証情報を入力します。
#### **`main.tf`**
```
provider "aws" {
  access_key = "xxxxxxxx"
  secret_key = "xxxxxxxxxxxxxxxxxxxxxxx"
  region     = "us-xxxx-x"
}
```

プロジェクトアクセスキーとWhaTapサーバーIPを入力します。
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

## 適用
修正したTerraform構成を適用します。

```
terraform apply
```
