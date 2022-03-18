provider "aws" {
  region  = "eu-west-1"
}

resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "eu-west-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "eu-west-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "eu-west-1c"
}

#resource "aws_ecr_repository" "mberman_ecr_repo_httpd" {
#  name = "mberman-ecr-repo/httpd"
#}

resource "aws_ecs_cluster" "bluevine_cluster" {
  name = "bluevine-cluster"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
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

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###### LOGSTASH ######  
resource "aws_ecs_task_definition" "logstash_task" {
  family                   = "logstash_task"
  container_definitions    = <<DEFINITION
  [
      {
         "essential": true,
         "image": "577060021721.dkr.ecr.eu-west-1.amazonaws.com/mberman-ecr-repo/logstash-8.1.0-mberman:latest",
         "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
               "awslogs-group" : "/ecs/fargate-task-definition",
               "awslogs-region": "eu-west-1",
               "awslogs-stream-prefix": "ecs"
            }
         },
         "name": "logstash_task",
         "portMappings": [
            {
               "containerPort": 8090,
               "hostPort": 8090,
               "protocol": "tcp"
            }
         ]
      }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 2048
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "logstash_service" {
  name            = "logstash-service"
  cluster         = aws_ecs_cluster.bluevine_cluster.id
  task_definition = aws_ecs_task_definition.logstash_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  
  load_balancer {
    target_group_arn = "${aws_lb_target_group.logstash_target_group.arn}" 
    container_name   = "${aws_ecs_task_definition.logstash_task.family}"
    container_port   = 8090
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    security_groups  = ["${aws_security_group.load_balancer_security_group.id}","${aws_security_group.logstash_security_group.id}"]
    assign_public_ip = true
  }
}

resource "aws_security_group" "logstash_security_group" {
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0    # Allowing any incoming port
    to_port     = 0    # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "logstash_load_balancer" {
  name               = "logstash-alb"
  load_balancer_type = "application"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  security_groups = ["${aws_security_group.logstash_security_group.id}"]
}

resource "aws_lb_target_group" "logstash_target_group" {
  name        = "logstash-target-group"
  port        = 8090
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}

resource "aws_lb_listener" "logstash_listener" {
  load_balancer_arn = "${aws_alb.logstash_load_balancer.arn}" 
  port              = "8090"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logstash_target_group.arn}" 
  }
}

###### HTTP ######
resource "aws_ecs_task_definition" "httpd_task" {
  family                   = "httpd_task"
  container_definitions    = <<DEFINITION
  [
      {
         "essential":true,
         "image":"906394416424.dkr.ecr.us-east-1.amazonaws.com/aws-for-fluent-bit:stable",
         "name":"log_router",
         "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
               "awslogs-group" : "/ecs/fargate-task-definition",
               "awslogs-region": "eu-west-1",
               "awslogs-stream-prefix": "ecs"
            }
         },
         "firelensConfiguration":{
             "type":"fluentbit"
         },
         "memoryReservation":50
      },
      {
         "command": [
            "/bin/sh -c \"echo '<html> <head> <title>Bluevine</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Hello World!!!</h1> <h2>Max Berman</h2> <p>March, 2022</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
         ],
         "entryPoint": [
            "sh",
            "-c"
         ],
         "essential": true,
         "image": "httpd:2.4",
         "logConfiguration": {
            "logDriver": "awsfirelens",
               "options": {
                "Name": "http",
                "Host": "aws_alb.logstash_load_balancer.dns_name",
                "Port": "8090",
                "Format": "json"
            }
         },
         "name": "httpd_task",
         "portMappings": [
            {
               "containerPort": 80,
               "hostPort": 80,
               "protocol": "tcp"
            }
         ]
      }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0    # Allowing any incoming port
    to_port     = 0    # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "application_load_balancer" {
  name               = "bluevine-alb"
  load_balancer_type = "application"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_lb_target_group" "http_target_group" {
  name        = "http-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}

resource "aws_ecs_service" "httpd_service" {
  name            = "httpd-service"
  cluster         = aws_ecs_cluster.bluevine_cluster.id
  task_definition = aws_ecs_task_definition.httpd_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  
  load_balancer {
    target_group_arn = "${aws_lb_target_group.http_target_group.arn}" 
    container_name   = "${aws_ecs_task_definition.httpd_task.family}"
    container_port   = 80
  }
  
  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    security_groups  = ["${aws_security_group.load_balancer_security_group.id}","${aws_security_group.logstash_security_group.id}"]
    assign_public_ip = true
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}" 
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.http_target_group.arn}" 
  }
}

###### Route53 ######
resource "aws_route53_record" "www" {
  zone_id = "Z03953912FAQYX9QC55AM"
  name    = "www.mberman.co.uk"
  type    = "A"

  alias {
    name                   = aws_alb.application_load_balancer.dns_name
    zone_id                = aws_alb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}
