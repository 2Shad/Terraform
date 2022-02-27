resource "aws_vpc" "shadman_tf_vpc_asg" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    
    tags = {
        Name = "eng103a_shadman_tf_vpc_asg"
    }
}


resource "aws_security_group" "shadman_tf_sg_asg" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.shadman_tf_vpc_asg.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["147.12.250.227/32", "34.241.78.77/32"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "eng103a_shadman_tf_sg"
  }
}


resource "aws_internet_gateway" "shadman_tf_vpc_ig_asg" {
  vpc_id = aws_vpc.shadman_tf_vpc_asg.id

  tags = {
    Name = "eng103a_shadman_tf_ig_asg"
  }
}


resource "aws_subnet" "shadman_tf_subnet_asg_1" {
  vpc_id     = aws_vpc.shadman_tf_vpc_asg.id
  cidr_block = "10.0.6.0/24"

  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "eng103a_shadman_tf_subnet_2"
  }
}


resource "aws_route_table" "shadman_tf_vpc_rt_asg_1" {
    vpc_id = aws_vpc.shadman_tf_vpc_asg.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.shadman_tf_vpc_ig_asg.id
    }

    tags = {
        Name = "eng103a_shadman_tf_rt_asg"
    }
}


resource "aws_route_table_association" "shadman_tf_rt_association_asg_1" {
    subnet_id = aws_subnet.shadman_tf_subnet_asg_1.id
    route_table_id = aws_route_table.shadman_tf_vpc_rt_asg_1.id
}

resource "aws_subnet" "shadman_tf_subnet_asg_2" {
  vpc_id     = aws_vpc.shadman_tf_vpc_asg.id
  cidr_block = "10.0.7.0/24"

  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "eng103a_shadman_tf_subnet_2"
  }
}


resource "aws_route_table" "shadman_tf_vpc_rt_asg_2" {
    vpc_id = aws_vpc.shadman_tf_vpc_asg.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.shadman_tf_vpc_ig_asg.id
    }

    tags = {
        Name = "eng103a_shadman_tf_rt"
    }
}


resource "aws_route_table_association" "shadman_tf_rt_association_asg_2" {
    subnet_id = aws_subnet.shadman_tf_subnet_asg_2.id
    route_table_id = aws_route_table.shadman_tf_vpc_rt_asg_2.id
}


resource "aws_subnet" "shadman_tf_subnet_asg_3" {
  vpc_id     = aws_vpc.shadman_tf_vpc_asg.id
  cidr_block = "10.0.8.0/24"

  availability_zone = "eu-west-1c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "eng103a_shadman_tf_subnet_2"
  }
}


resource "aws_route_table" "shadman_tf_vpc_rt_asg_3" {
    vpc_id = aws_vpc.shadman_tf_vpc_asg.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.shadman_tf_vpc_ig_asg.id
    }

    tags = {
        Name = "eng103a_shadman_tf_rt"
    }
}


resource "aws_route_table_association" "shadman_tf_rt_association_asg_3" {
    subnet_id = aws_subnet.shadman_tf_subnet_asg_3.id
    route_table_id = aws_route_table.shadman_tf_vpc_rt_asg_3.id
}




resource "aws_launch_configuration" "shadman" {
  name_prefix     = "tf-asg-shadman-"
  image_id        = "ami-090721a59330808d2"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.shadman_tf_sg_asg.id]

  key_name = "eng103a_shadman"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb" "shadman" {
  name               = "shadman-tf-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.shadman_tf_sg_asg.id]
  subnets            = [aws_subnet.shadman_tf_subnet_asg_1.id, aws_subnet.shadman_tf_subnet_asg_2.id, aws_subnet.shadman_tf_subnet_asg_3.id]
}


resource "aws_lb_target_group" "shadman" {
   name     = "shadman-asg"
   port     = 80
   protocol = "HTTP"
   vpc_id   = aws_vpc.shadman_tf_vpc_asg.id
}


resource "aws_lb_listener" "shadman" {
  load_balancer_arn = aws_lb.shadman.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shadman.arn
  }
}


resource "aws_autoscaling_attachment" "shadman" {
  autoscaling_group_name = aws_autoscaling_group.shadman.id
  alb_target_group_arn   = aws_lb_target_group.shadman.arn
}


resource "aws_autoscaling_group" "shadman" {
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.shadman.name
  vpc_zone_identifier  = [aws_subnet.shadman_tf_subnet_asg_1.id, aws_subnet.shadman_tf_subnet_asg_2.id, aws_subnet.shadman_tf_subnet_asg_3.id]
}


resource "aws_autoscaling_policy" "shadman_scale_up" {
  name                   = "shadman_scale_up"
  autoscaling_group_name = aws_autoscaling_group.shadman.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}


resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_actions       = [aws_autoscaling_policy.shadman_scale_up.arn]
  alarm_name          = "shadman_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "25"
  evaluation_periods  = "2"
  period              = "60"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.shadman.name
  }
}