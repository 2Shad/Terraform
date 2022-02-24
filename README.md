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

### Terraform script to create an EC2 instance, VPC, subnet, security group, Internet gateway, route table and the appropriate accociation.

```
resource "aws_instance" "shadman_tf_app" {

    ami = var.app_ami

    instance_type = var.instantance_type

    key_name= var.key_name

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


resource "aws_key_pair" "deployer" {
  key_name   = "aws_tf"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+C8B1ZgjSWqGtcaVwsa7Bo720MQR6XCCbMqCA9DMeJPbDz4eEqRRsdS3v8/CXlurWPZSjhe7nOigLzuq2xLqpApfTbZrCLbHmGw8I7iZnrpfho7i9KNOZG/qIKymLMC5Y+zLNDGzQBK8RYeeceE1uf0jN0YzDxoeWXYkyddlcEvvjI+oPTpmw2F/4RXwqIVr3BVu0igo7ZI99NggWzgVswH2ndog+iihXsLOMX2/5tWrVNU4GUlknmEAdehtOmKf5tN8w/SbHxAEbaEnayrqncbqNs6qmhr1sNafHBZVuVWfLaC8AUwLrlRSDhnT7G9M/2TFfFY9NZLaRf5Ig5OqH abc@0f0541c92239"
}


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
```