############################################# TERRAFORM #############################################
resource "aws_lb" "alb" {
  name               = join("-", [lower(var.prefix), "alb", lower(var.environment), "${random_string.suffix.result}", format("%02d", sum([var.number_of_sequence, 0]))])
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  enable_deletion_protection = false

  tags = {
    "Environment" = var.environment
  }

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.public_subnet_a,
    aws_subnet.public_subnet_b,
    aws_subnet.private_subnet_a,
    aws_subnet.private_subnet_b,
    aws_nat_gateway.ngw,
    aws_internet_gateway.igw,
    aws_security_group.sg_app,
    aws_security_group.sg_lb
  ]
}

resource "aws_lb_target_group" "target_group" {
  name     = join("-", [lower(var.prefix), "tg", lower(var.environment), "${random_string.suffix.result}", format("%02d", sum([var.number_of_sequence, 0]))])
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol            = "HTTP"
    path                = "/index.html"
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }

  depends_on = [
    aws_lb.alb
  ]
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  count = length(aws_instance.ec2_linux)

  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.ec2_linux[count.index].id
  port             = 80

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.public_subnet_a,
    aws_subnet.public_subnet_b,
    aws_subnet.private_subnet_a,
    aws_subnet.private_subnet_b,
    aws_nat_gateway.ngw,
    aws_internet_gateway.igw,
    aws_security_group.sg_app,
    aws_security_group.sg_lb,
    aws_lb.alb,
    aws_lb_target_group.target_group
  ]
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}