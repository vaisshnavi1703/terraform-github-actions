terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the default subnets from the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a new security group in the default VPC
resource "aws_security_group" "de" {
  name        = "de"
  description = "Security group def for example EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (adjust for your security)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound
  }

  tags = {
    Name = "de"
  }
}

# Use an existing key pair
data "aws_key_pair" "database" {
  key_name = "database"
}

# EC2 instance using default VPC, subnet, and new security group
resource "aws_instance" "example_ec21" {
  ami                  = "ami-084568db4383264d4"  # Amazon Linux 2 AMI
  instance_type        = "t2.micro"
  subnet_id            = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.de.id]
  key_name             = data.aws_key_pair.example_key.key_name

  tags = {
    Name = "example-ec21-instance"
  }
}
