provider "aws" {
  profile = "default"
  region = "us-east-1"
}
resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_az2" {
availability_zone = "us-east-1b"
}

resource "aws_security_group" "dev_web" {
  name        = "dev_web"
  description = "Allow standard http and https ports inbound and everything outbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
}
resource "aws_instance" "dev_web"{
ami = "ami-03182335d07b05f7a"
instance_type = "t2.micro"
vpc_security_group_ids = [aws_security_group.dev_web.id]
}
resource "aws_elb" "dev_web" {
name =  "prod-web"
instances = aws_instance.dev_web.*.id
subnets    = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az1.id]
security_groups = [aws_security_group.dev_web.id]
tags = {
"Terraform" : "true"}

listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
}
