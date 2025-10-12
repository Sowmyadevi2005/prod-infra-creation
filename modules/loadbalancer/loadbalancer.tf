#############################################
# Application Load Balancer (ALB)
# --------------------------------------------
# Creates an internet-facing ALB in public subnets
# to distribute HTTP traffic to EC2 instances.
#############################################
resource "aws_lb" "app_lb" {
  name               = var.alb_name
  internal           = false                        # ALB accessible from the Internet
  load_balancer_type = "application"                 # Application Layer (L7)
  security_groups    = [var.alb_sg_id]               # ALB Security Group
  subnets            = var.public_subnets            # Public subnets (VPC 1)

  tags = {
    Name        = var.alb_name
    Project     = "L2-Track"
    Environment = "prod"
    Component   = "Application-LoadBalancer"
    ManagedBy   = "Terraform"
  }
}

#############################################
# Target Group for ALB
# --------------------------------------------
# Defines the backend group of EC2 instances
# that the ALB forwards traffic to.
#############################################
resource "aws_lb_target_group" "tg" {
  name        = var.lb_target_group_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Health check configuration for targets
  health_check {
    path                = "/phpinfo.php"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  # Enable session stickiness via ALB cookie
  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  tags = {
    Name        = var.lb_target_group_name
    Project     = "L2-Track"
    Environment = "prod"
    Component   = "Target-Group"
    ManagedBy   = "Terraform"
  }
}

#############################################
# HTTP Listener for ALB
# --------------------------------------------
# Listens for HTTP (port 80) traffic and forwards
# it to the defined target group.
#############################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = {
    Name        = "alb-http-listener"
    Project     = "L2-Track"
    Environment = "prod"
    Component   = "Listener-HTTP"
    ManagedBy   = "Terraform"
  }
}
