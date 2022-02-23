variable "app_ami" {
    default = "ami-07d8796a2b0f8d29c"
}

variable "name" {
    default = "shadman_tf_app"
}

variable "instantance_type" {
    default = "t2.micro"
}

variable "key_name" {
    default = "aws_tf"
}

variable "region" {
    default = "eu-west-1"
}

variable "tag_name" {
    default = "eng103a_shadman_tf_app"
}