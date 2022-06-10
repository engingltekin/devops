//User needs to select appropriate key name and should put his/her own pem file in the relevant places when launching the template.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  #  secret_key = ""
  #  access_key = ""
}

variable "tags" {
  default = ["postgresql", "nodejs", "react"]
}


resource "aws_instance" "postgres_node" {
  ami = var.myami
  instance_type = var.instancetype
  key_name = var.mykey
  iam_instance_profile = aws_iam_instance_profile.ec2full.name
  vpc_security_group_ids = [aws_security_group.postgres-sec-gr.id]
  tags = {
    Name = "ansible_postgres"
    stack = var.stack
    environment = var.env
  }
}

resource "aws_instance" "react_node" {
  ami = var.myami
  instance_type = var.instancetype
  key_name = var.mykey
  iam_instance_profile = aws_iam_instance_profile.ec2full.name
  vpc_security_group_ids = [aws_security_group.react-sec-gr.id]
  tags = {
    Name = "ansible_react"
    stack = var.stack
    environment = var.env
  }
}

resource "aws_instance" "nodejs_node" {
  ami = var.myami
  instance_type = var.instancetype
  key_name = var.mykey
  iam_instance_profile = aws_iam_instance_profile.ec2full.name
  vpc_security_group_ids = [aws_security_group.nodejs-sec-gr.id]
  tags = {
    Name = "ansible_nodejs"
    stack = var.stack
    environment = var.env
  }
}

resource "aws_iam_role" "ec2full" {
  name = "projectec2full"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
}

resource "aws_iam_instance_profile" "ec2full" {
  name = "projectec2full"
  role = aws_iam_role.ec2full.name
}

resource "aws_security_group" "postgres-sec-gr" {
  name = "project208-postgres-sec-gr"
  tags = {
    Name = "project208-postgres-sec-gr"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    security_groups = [aws_security_group.nodejs-sec-gr.id]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "react-sec-gr" {
  name = "project208-react-sec-gr"
  tags = {
    Name = "project208-react-sec-gr"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    protocol    = "tcp"
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nodejs-sec-gr" {
  name = "project208-nodejs-sec-gr"
  tags = {
    Name = "project208-nodejs-sec-gr"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    protocol    = "tcp"
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}