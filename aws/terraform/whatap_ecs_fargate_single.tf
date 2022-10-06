


resource "aws_ecs_task_definition" "app" {
  family                   = "${var.whatapsingle}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  # defined in role.tf
  task_role_arn = aws_iam_role.app_role.arn
  

  container_definitions = <<DEFINITION
[
  {
    "name": "whatap-single",
    "image": "whatap/ecs_mon",
    "essential": true,
    "environment": [
      {
        "name": "ACCESSKEY",
        "value": "${var.whatap_accesskey}"
      },
      {
        "name": "WHATAP_HOST",
        "value": "${var.whatap_host}"
      },
      {
        "name": "FARGATE_HELPER",
        "value": "true"
      }
    ],
    
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.whatapsingle}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION

}

resource "aws_ecs_service" "app" {
  name            = "${var.whatapsingle}"
  cluster         = "${var.clusterarn}"
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  network_configuration {
    security_groups = ["${var.sg-group}"]
    subnets         = ["${var.subnet1}","${var.subnet2}"]
    assign_public_ip = true
  }
  
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.whatapsingle}-ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_role" {
  name               = "${var.whatapsingle}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  
}

resource "aws_iam_role_policy" "app_policy" {
  name   = "${var.whatapsingle}"
  role   = aws_iam_role.app_role.id
  policy = data.aws_iam_policy_document.app_policy.json
}

data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
        "ecs:Describe*",
        "ecs:List*"
    ]
    resources = [
      "*"
    ]
  }
}


resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "logs_retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${var.whatapsingle}"
  retention_in_days = var.logs_retention_in_days
}