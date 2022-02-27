# Infrastructure as Code with Terraform
## What is Terraform
### Terraform Architecture
#### Terraform default file/folder structure
##### .gitignore
###### AWS keys with Terraform security


### Terraform commands
- `terraform init` To initialize Terraform
- `terraform plan` checks the script
- `terraform apply` implements the script
- `terraform destroy` to delete everything

### Terraform file/folder structure
- `.tf` extension - `main.tf` (runner file)
- Apply **DRY**

### Set up AWS keys as an ENV in windows machine
- `AWS_ACCESS_KEY_ID` for aws access keys
- `AWS_SECRET_ACCESS_KEY` for aws secret key
- Windows search `env` and open **Edit the system Environment variable**
- Select **Environment Variables**
- Under **User variables for $User** select **New** and add the 2 variables

### Set-up ssh keys
Generate ssh keys by `ssh-keygen -t rsa -b 2048`.

#### To add the keys to terraform add `key_name= "aws_key"` to the `"aws_instance"` resource, in the same resource also add a `connection` section:
```
connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/home/user/.ssh/aws_key")
      timeout     = "4m"
   }
```

#### You also need to add another `aws_key_pair` resource in the file:
```
resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbvRN/gvQBhFe+dE8p3Q865T/xTKgjqTjj56p1IIKbq8SDyOybE8ia0rMPcBLAKds+wjePIYpTtRxT9UsUbZJTgF+SGSG2dC6+ohCQpi6F3xM7ryL9fy3BNCT5aPrwbR862jcOIfv7R1xVfH8OS0WZa8DpVy5kTeutsuH5suehdngba4KhYLTzIdhM7UKJvNoUMRBaxAqIAThqH9Vt/iR1WpXgazoPw6dyPssa7ye6tUPRipmPTZukfpxcPlsqytXWlXm7R89xAY9OXkdPPVsrQdkdfhnY8aFb9XaZP8cm7EOVRdxMsA1DyWMVZOTjhBwCHfEIGoePAS3jFMqQjGWQd user@pc"
}
```

## Terraform script to create an EC2 instance, VPC, subnet, security group, Internet gateway, route table and the appropriate accociation.

### EC2 deployment

#### Basic EC2 deployment
```
resource "aws_instance" "instance_name" {

    ami = "ami_name"

    instance_type = "t2.micro"

    key_name= "key_name"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/config/.ssh/key_name")
      timeout     = "4m"
    }

}
```


#### Additional Arguments
- To enable public IP on instance `associate_public_ip_address = true`.
- Assign security Group `vpc_security_group_ids = ["security_group_id"]`.  (or `aws_security_group.security_group_name.id`)
- Assign subnet `subnet_id = "subnet_id"`.  (or `aws_subnet.subnet_name.id`)
- Tags 
```
    tags = {
        Name = "name"
    }
```

#### Deploy a new ssh key to AWS
```
resource "aws_key_pair" "deployer" {
  key_name   = "key_name"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+C8B1ZgjSWqGtcaVwsa7Bo720MQR6XCCbMqCA9DMeJPbDz4eEqRRsdS3v8/CXlurWPZSjhe7nOigLzuq2xLqpApfTbZrCLbHmGw8I7iZnrpfho7i9KNOZG/qIKymLMC5Y+zLNDGzQBK8RYeeceE1uf0jN0YzDxoeWXYkyddlcEvvjI+oPTpmw2F/4RXwqIVr3BVu0igo7ZI99NggWzgVswH2ndog+iihXsLOMX2/5tWrVNU4GUlknmEAdehtOmKf5tN8w/SbHxAEbaEnayrqncbqNs6qmhr1sNafHBZVuVWfLaC8AUwLrlRSDhnT7G9M/2TFfFY9NZLaRf5Ig5OqH abc@0f0541c92239"
}
```

### Create an AWS VPC using terraform

#### VPC

```
resource "aws_vpc" "vpc_name" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    
    tags = {
        Name = "name"
    }
}
```

#### Subnet

```
resource "aws_subnet" "subnet_name" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "name"
  }
}
```

#### Security Group

```
resource "aws_security_group" "security_group_name" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["1.2.3.4/32", "34.241.78.77/32"]
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
    Name = "name"
  }
}
```

#### Internet Gateway

```
resource "aws_internet_gateway" "internet_gateway_name" {
  vpc_id = aws_vpc.vpc_name.id

  tags = {
    Name = "name"
  }
}
```

#### Route Table

```
resource "aws_route_table" "route_table_name" {
    vpc_id = aws_vpc.vpc_name.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway_name.id
    }

    tags = {
        Name = "name"
    }
}
```

#### Associating 

```
resource "aws_route_table_association" "association_name" {
    subnet_id = aws_subnet.subnet_name.id
    route_table_id = aws_route_table.route_table_name.id
}
```

## Creating Auto-Scaling group with Terraform

Create at least 2 subnets in different avaliability zones using: 
```
  availability_zone = "eu-west-1a"
```

Additionally you might want to add a public IP to the instances, by adding `map_public_ip_on_launch = "true"` argument in the subnet resources.

### Create a Auto-Scaling launch configuration, if needed.

```
resource "aws_launch_configuration" "launch_configuration_name" {
  name_prefix     = "name-"
  image_id        = "ami_id"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.security_group_name.id]

  key_name = "key_name"

  lifecycle {
    create_before_destroy = true
  }
}
```

### Create a Load Balences, if needed.

```
resource "aws_lb" "lb_name" {
  name               = "lb_name"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group_name.id]
  subnets            = [aws_subnet.subnet_1_name.id, aws_subnet.subnet_2_name.id, aws_subnet.subnet_3_name.id]
}
```

### Create a Load Balencer Target Group, if needed.

```
resource "aws_lb_target_group" "target_group_name" {
   name     = "target_group_name"
   port     = 80
   protocol = "HTTP"
   vpc_id   = aws_vpc.vpc_name.id
}
```

### Create a Load Balencer Lisener

```
resource "aws_lb_listener" "listener_name" {
  load_balancer_arn = aws_lb.lb_name.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_name.arn
  }
}
```

### Attach Target Group to Auto-Scaling Group.

```
resource "aws_autoscaling_attachment" "attachment_name" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group_name.id
  alb_target_group_arn   = aws_lb_target_group.target_group_name.arn
}
```

### Set min, max and desired capacity for the Auto-Scaling group.

```
resource "aws_autoscaling_group" "name" {
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.launch_configuration_name.name
  vpc_zone_identifier  = [aws_subnet.subnet_1_name.id, aws_subnet.subnet_2_name.id, aws_subnet.subnet_3_name.id]
}
```

### Set scaling rules.

```
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group_name.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1   #(-1 for scaling down)
  cooldown               = 120
}
```

### Set CloudWatch alarm for said scaling rules.

```
resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  alarm_name          = "scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "25"
  evaluation_periods  = "2"
  period              = "60"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group_name.name
  }
}
```