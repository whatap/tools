
resource "aws_ecs_task_definition" "simpleapp" {
  family                   = "${var.simpleapp}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.simpleTaskExecutionRole.arn

  # defined in role.tf
  task_role_arn = aws_iam_role.simpleapp_role.arn
  

  container_definitions = <<DEFINITION
[
  {
    "name": "simple-user-app",
    "image": "registry.whatap.io:5000/dev/hsnam:0714",
    "essential": true,
    "portMappings": [ 
        { 
            "containerPort": 8000,
            "hostPort": 8000,
            "protocol": "tcp"
        }
    ],    
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.simpleapp}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  },
  {
    "name": "whatap-sidecar",
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
      }
    ],
    
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.simpleapp}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION

}

resource "aws_ecs_service" "simpleapp" {
  name            = "${var.simpleapp}"
  cluster         = "${var.clusterarn}"
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.simpleapp.arn
  desired_count   = 1

  network_configuration {
    security_groups = ["${var.sg-group}"]
    subnets         = ["${var.subnet1}","${var.subnet2}"]
    assign_public_ip = true
  }
  
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

}



resource "aws_iam_role" "simpleTaskExecutionRole" {
  name               = "${var.simpleapp}-ecs"
  assume_role_policy = data.aws_iam_policy_document.simple_assume_role_policy.json
}

data "aws_iam_policy_document" "simple_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "simpleTaskExecutionRole_policy" {
  role       = aws_iam_role.simpleTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "simpleapp_role" {
  name               = "${var.simpleapp}"
  assume_role_policy = data.aws_iam_policy_document.simple_assume_role_policy.json
}



resource "aws_iam_role_policy" "simpelapp_policy" {
  name   = "${var.simpleapp}"
  role   = aws_iam_role.simpleapp_role.id
  policy = data.aws_iam_policy_document.simpelapp_policy.json
}

data "aws_iam_policy_document" "simpelapp_policy" {
  statement {
    actions = [
      "ecs:DescribeClusters","ecs:DescribeTasks"
    ]

    resources = [
      "*"
    ]
  }
}


resource "aws_cloudwatch_log_group" "simplelogs" {
  name              = "/fargate/service/${var.simpleapp}"
  retention_in_days = var.logs_retention_in_days
}
