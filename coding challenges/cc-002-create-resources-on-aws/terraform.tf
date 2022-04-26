provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source         = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

data "aws_vpc" "main_vpc" {
  default = true
}

data "aws_ami" "tf_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

locals {
  instance_type = "t2.micro"
  keyname       = "Engin_Linux"
}

variable "props1" {
  type = map(string)
  default = {
    "Name" = "Terraform First Instance"
  }

}

variable "props2" {
  type = map(string)
  default = {
    "Name" = "Terraform Second Instance"
  }

}

resource "aws_security_group" "ec2-instance-SG" {
  name        = "Ec2-SG"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.main_vpc.id
  // To Allow SSH Transport
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instances" {
  for_each = {
    "first_instance" = var.props1
    second_instance  = var.props2
  }
  instance_type = local.instance_type
  ami           = data.aws_ami.tf_ami.id
  key_name      = local.keyname

  vpc_security_group_ids = [aws_security_group.ec2-instance-SG.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              cd /var/www/html
              echo 'Hello Terraform' >>index.html  
	            EOF
  tags = {
    "Name" = each.value["Name"]
  }

  provisioner "file" {
    content     = self.public_ip
    destination = "/home/ec2-user/my_public_ip.txt"
  }

  provisioner "file" {
    content     = self.private_ip
    destination = "/home/ec2-user/my_private_ip.txt"
  }

}

output "publicip" {
  value       = aws_instance.instances[*].public_ip
}

