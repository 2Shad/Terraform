# Terraform init will download any required packages


# define cloud povider
provider "aws"{
    
# define region
    region = var.region
}


# define what we want to launch
# Automate the process of creating EC2 instance


# name of the resource
resource "aws_instance" "shadman_tf_app" {

    # which AMI to use 
    ami = var.app_ami

    # define instance type
    instance_type = var.instantance_type

    # define ssh key
    key_name= var.key_name

    # Enable public IP?
    associate_public_ip_address = true

    vpc_security_group_ids = [aws_security_group.shadman_tf_sg.id]

    subnet_id = aws_subnet.shadman_tf_subnet.id

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/config/.ssh/aws_tf")
      timeout     = "4m"
    }

    # Name of the instance
    tags = {
        Name = var.tag_name
    }
}


# resource "aws_key_pair" "deployer" {
#   key_name   = "aws_tf"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+C8B1ZgjSWqGtcaVwsa7Bo720MQR6XCCbMqCA9DMeJPbDz4eEqRRsdS3v8/CXlurWPZSjhe7nOigLzuq2xLqpApfTbZrCLbHmGw8I7iZnrpfho7i9KNOZG/qIKymLMC5Y+zLNDGzQBK8RYeeceE1uf0jN0YzDxoeWXYkyddlcEvvjI+oPTpmw2F/4RXwqIVr3BVu0igo7ZI99NggWzgVswH2ndog+iihXsLOMX2/5tWrVNU4GUlknmEAdehtOmKf5tN8w/SbHxAEbaEnayrqncbqNs6qmhr1sNafHBZVuVWfLaC8AUwLrlRSDhnT7G9M/2TFfFY9NZLaRf5Ig5OqH abc@0f0541c92239"
# }


resource "aws_vpc" "shadman_tf_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    
    tags = {
        Name = "eng103a_shadman_tf_vpc"
    }
}


resource "aws_subnet" "shadman_tf_subnet" {
  vpc_id     = aws_vpc.shadman_tf_vpc.id
  cidr_block = "10.0.1.0/24"
#  map_public_ip_on_launch = "true"
#  availability_zone = "eu-west-1a"

  tags = {
    Name = "eng103a_shadman_tf_subnet"
  }
}


resource "aws_security_group" "shadman_tf_sg" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.shadman_tf_vpc.id

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


resource "aws_internet_gateway" "shadman_tf_vpc_ig" {
  vpc_id = aws_vpc.shadman_tf_vpc.id

  tags = {
    Name = "eng103a_shadman_tf_ig"
  }
}


resource "aws_route_table" "shadman_tf_vpc_rt" {
    vpc_id = aws_vpc.shadman_tf_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.shadman_tf_vpc_ig.id
    }

    tags = {
        Name = "eng103a_shadman_tf_rt"
    }
}


resource "aws_route_table_association" "shadman_tf_rt_association" {
    subnet_id = aws_subnet.shadman_tf_subnet.id
    route_table_id = aws_route_table.shadman_tf_vpc_rt.id
}