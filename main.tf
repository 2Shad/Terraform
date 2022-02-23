# Terraform init will download any required packages


# define cloud povider
provider "aws"{
    
# define region
    region = "eu-west-1"
}


# define what we want to launch
# Automate the process of creating EC2 instance

# name of the resource
resource "aws_instance" "shadman_tf_app" {

    # which AMI to use 
    ami = "ami-07d8796a2b0f8d29c"

    # define instance type
    instance_type = "t2.micro"

    # define ssh key
    key_name= "aws_tf"

    # Enable public IP?
    associate_public_ip_address = true

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/config/.ssh/aws_tf")
      timeout     = "4m"
    }

    # Name of the instance
    tags = {
        Name = "eng103a_shadman_tf_app"
    }
}
resource "aws_key_pair" "deployer" {
  key_name   = "aws_tf"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+C8B1ZgjSWqGtcaVwsa7Bo720MQR6XCCbMqCA9DMeJPbDz4eEqRRsdS3v8/CXlurWPZSjhe7nOigLzuq2xLqpApfTbZrCLbHmGw8I7iZnrpfho7i9KNOZG/qIKymLMC5Y+zLNDGzQBK8RYeeceE1uf0jN0YzDxoeWXYkyddlcEvvjI+oPTpmw2F/4RXwqIVr3BVu0igo7ZI99NggWzgVswH2ndog+iihXsLOMX2/5tWrVNU4GUlknmEAdehtOmKf5tN8w/SbHxAEbaEnayrqncbqNs6qmhr1sNafHBZVuVWfLaC8AUwLrlRSDhnT7G9M/2TFfFY9NZLaRf5Ig5OqH abc@0f0541c92239"
}