# ---------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------

resource "aws_lb" "app" {
  name               = "${local.common_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  tags = {
    Name = "${local.common_name}-alb"
  }
}


# ---------------------------------------------------------
# Target Group
# ---------------------------------------------------------

resource "aws_lb_target_group" "app" {
  name     = "${local.common_name}-tg"
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "${local.common_name}-target-group"
  }
}


# ---------------------------------------------------------
# Register EC2 Instances with Target Group
# ---------------------------------------------------------

resource "aws_lb_target_group_attachment" "app" {
  count = length(aws_instance.app)

  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}


# ---------------------------------------------------------
# ALB Listener
# ---------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}