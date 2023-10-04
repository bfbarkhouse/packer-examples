resource "aws_ecs_cluster" "cluster" {
  name = "bbarkhouse-ecs-cluster"
}
resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = "arn:aws:iam::983083522813:role/ecsTaskExecutionRole"

  container_definitions = <<DEFINITION
[
  {
    "image": "983083522813.dkr.ecr.us-east-1.amazonaws.com/bbarkhouse-docker-nginx:latest",
    "cpu": 1024,
    "memory": 2048,
    "name": "nginx",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}
resource "aws_security_group" "nginx_sg" {
  name   = "nginx-task-security-group"
  vpc_id = aws_vpc.bbarkhouse-ecs-vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.nginx_sg.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.id
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.lb_listener]
}


