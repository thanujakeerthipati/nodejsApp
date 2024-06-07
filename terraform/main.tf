resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-template"
  image_id      = "ami-00beae93a2d981137"
  instance_type = "t3.micro"

  key_name               = "terraform"
  vpc_security_group_ids = ["sg-03ceb76996b12bbcf"]
  iam_instance_profile {
    name = "ecs-app-role"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name     = "ecs-terraform"
      function = "ecs"
    }
  }

  user_data = filebase64("${path.module}/ecs.sh")
}

resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = ["subnet-0cdf1fce24182b5ee", "subnet-0338c2ba654a26edf"]
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-03ceb76996b12bbcf"]
  subnets            = ["subnet-0cdf1fce24182b5ee", "subnet-0338c2ba654a26edf"]

  tags = {
    Name = "ecs-alb"
  }
}

resource "aws_lb_listener" "task" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "app-helloworld-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-057a8656f31aa6137"

  health_check {
    path = "/"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-app-cluster"
}


resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "my-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = "arn:aws:iam::315412305892:role/ecs-app-role"
  cpu                      = 1024
  memory                   = 2048
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name      = "helloworld"
      image     = "315412305892.dkr.ecr.us-east-1.amazonaws.com/ecs-app:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = ["subnet-0cdf1fce24182b5ee", "subnet-0338c2ba654a26edf"]
    security_groups = ["sg-03ceb76996b12bbcf"]
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "helloworld"
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}