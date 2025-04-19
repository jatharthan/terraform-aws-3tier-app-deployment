#app tier
#launch template for app tier
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "${var.project_prefix}-app-lt-"
  image_id      = "ami-07a6f770277670015"
  instance_type = "t3.medium"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name 
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.private_app_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/app-userdata.sh", {}))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_prefix}-app-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_prefix}-app-launch-template"
  }
}

#target group for internal loadbalancer
resource "aws_lb_target_group" "app_target_group" {
  name     = "${var.project_prefix}-app-target-group"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
    port                = 4000
  }

  tags = {
    Name = "${var.project_prefix}-app-target-group"
  }
}

#internal loadbalancer

resource "aws_lb" "internal_app_lb" {
  name               = "${var.project_prefix}-internal-app-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_lb_sg.id]  # The security group created for the internal load balancer
  subnets            = [
    aws_subnet.private_app_az1.id,  # Subnet in availability zone 1
    aws_subnet.private_app_az2.id   # Subnet in availability zone 2
  ]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_prefix}-internal-app-lb"
  }
}

resource "aws_lb_listener" "internal_app_listener" {
  load_balancer_arn = aws_lb.internal_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }

  tags = {
    Name = "${var.project_prefix}-internal-app-listener"
  }
}


#app tier autoscaling group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2
  min_size             = 2
  max_size             = 3
  name                 = "${var.project_prefix}-app-asg"
  vpc_zone_identifier  = [
    aws_subnet.private_app_az1.id,  # Private subnet in availability zone 1
    aws_subnet.private_app_az2.id   # Private subnet in availability zone 2
  ]
  launch_template {
    id      = aws_launch_template.app_launch_template.id  # The Launch Template we created earlier
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.app_target_group.arn  # Target group created for internal load balancer
  ]
  
  health_check_type          = "ELB"
  health_check_grace_period = 300
  force_delete              = true
  wait_for_capacity_timeout  = "0"
  
  # Correct tag block for Auto Scaling group
  tag {
    key                 = "Name"
    value               = "${var.project_prefix}-app-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Webtier
#launch template for web tier
resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "${var.project_prefix}-web-lt-"
  image_id      = "ami-07a6f770277670015" # Web tier AMI
  instance_type = "t3.medium"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.public_web_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/web-userdata.sh", {}))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_prefix}-web-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_prefix}-web-launch-template"
  }
}

#target group for external loadbalancer
resource "aws_lb_target_group" "web_target_group" {
  name     = "${var.project_prefix}-web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 3
    healthy_threshold   = 3
    port                = 80
  }

  tags = {
    Name = "${var.project_prefix}-web-target-group"
  }
}

#loadbalancer for external
resource "aws_lb" "external_web_lb" {
  name               = "${var.project_prefix}-external-web-lb"
  internal           = false  # public-facing load balancer
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_lb_sg.id]
  subnets            = [
    aws_subnet.public_web_az1.id,  # Public subnet in AZ1
    aws_subnet.public_web_az2.id   # Public subnet in AZ2
  ]
  enable_deletion_protection      = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_prefix}-external-web-lb"
  }
}

resource "aws_lb_listener" "external_web_listener" {
  load_balancer_arn = aws_lb.external_web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }

  tags = {
    Name = "${var.project_prefix}-external-web-listener"
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 1
  min_size             = 1
  max_size             = 2
  name                 = "${var.project_prefix}-web-asg"
  vpc_zone_identifier  = [
    aws_subnet.public_web_az1.id,  # Public subnet in AZ1
    aws_subnet.public_web_az2.id   # Public subnet in AZ2
  ]

  launch_template {
    id      = aws_launch_template.web_launch_template.id  # You'll create this separately
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.web_target_group.arn  # The target group for the external ALB
  ]

  health_check_type          = "ELB"
  health_check_grace_period = 300
  force_delete               = true
  wait_for_capacity_timeout  = "0"

  tag {
    key                 = "Name"
    value               = "${var.project_prefix}-web-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}




