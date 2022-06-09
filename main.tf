terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.main_region
}

resource "aws_security_group" "EC2_SG" {
  name        = "EC2_SG"
  description = "Allows HTTP, HTTPS and SSH from single location"
  vpc_id      = var.main_region_vpc_id

  ingress {
    description      = "HTTP connectivity"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS connectivity"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH connectivity (specific)"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["151.36.230.179/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "terraform_instance" {
  ami           = "ami-0811f38eb070bf860"
  instance_type = "t3.micro"
  key_name      = "milan-key"
  vpc_security_group_ids = [
    aws_security_group.EC2_SG.id
  ]
}