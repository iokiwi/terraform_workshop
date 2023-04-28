terraform {
    required_version = ">= 1.4.4"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

provider "aws" {
    region = "ap-southeast-2"
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

  filter {
    name   = "name"
    values = ["ubuntu*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["099720109477"] # Canonical's owner ID
}

output "ubuntu_la" {
    value = data.aws_ami.ubuntu_latest
}